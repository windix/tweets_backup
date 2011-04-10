class Tweet < ActiveRecord::Base
  TWEETS_PER_PAGE = 200
  
  self.inheritance_column = :not_in_use

  def self.get_client
    unless @client
      config = YAML.load_file(TweetsRails::Application::config.twitter_config_file)
  
      @client = TwitterOAuth::Client.new(
        :proxy => config['api']['url'] || 'http://api.twitter.com',
        :consumer_key => config['oauth']['consumer_key'],
        :consumer_secret => config['oauth']['consumer_secret'],
        :token => config['oauth']['request_token'],
        :secret => config['oauth']['request_secret']
      )
    end
    
    @client
  end
  
  def self.save_tweet(type, t)
    Tweet.create(
      :type => type,
      :external_id => t['id'],
      :posted_at => DateTime.parse(t['created_at']),
      :in_reply_to_user_id => t['in_reply_to_user_id'],
      :source => t['source'],
      :user_id => t['user']['id'],
      :user_name => t['user']['name'],
      :user_screen_name => t['user']['screen_name'],
      :text => t['text'],
      :raw => t.to_json
    )
  end
  
  def self.loop_through_tweets(type)
    page = 1
    stop = false

    loop do
      puts "current page: #{page}"

      tweets = yield page
      break if tweets.empty?

      tweets.each do |t|
        if Tweet.where(:type => type, :external_id => t['id']).empty?
          self.save_tweet type, t
          puts "##{t['id']} saved!"
        else
          # found this entry in db, which means we have reached the existing tweet
          puts "No new tweet, quit"
          stop = true
          break
        end
      end

      break if stop

      page += 1
    end
  end
  
  def self.backup_timeline
    client = self.get_client
    self.loop_through_tweets('tweet') do |page|
      client.user_timeline :count => TWEETS_PER_PAGE, :page => page
    end
  end
  
  def self.backup_favorite
    client = self.get_client
    self.loop_through_tweets('favorite') do |page|
      client.favorites :page => page
    end    
  end

  def post_date
    posted_at.strftime('%Y-%m-%d')
  end

  def post_time
    posted_at.strftime('%H:%M')
  end

  def twitter_perm_url
    "https://twitter.com/#!/#{user_screen_name}/status/#{external_id}"
  end

  def self.set_type(type)
    @type = type
  end

  def self.get_tweets
    where(:type => @type).order('posted_at ASC')   
  end

  def self.per_page
    20
  end

  def self.last_page_number(collections)
    total = collections.count
    [((total - 1) / per_page) + 1, 1].max
  end
end

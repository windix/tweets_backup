class TweetTasks < Thor
  require File.expand_path('../../', File::dirname(__FILE__)) + '/config/environment'

	desc "copy_config_file", "copy config file"
	def copy_config_file
	  config_path = "#{Rails.root}/config"
	  source = "#{config_path}/twitter.yml.example"
	  dest = "#{config_path}/twitter.yml"
	
	  if !File.exists?(dest)
	    FileUtils.cp(source, dest)
	    puts "Config file #{dest} copied"
	  else
	    puts "Skipping config file #{dest} because it exists"
	  end
	end
	
	desc "setup", "twitter oauth"
	def setup(subdomain = 'windix')
	  copy_config_file
	
    all_config = YAML.load_file(TweetsRails::Application.config.twitter_config_file) rescue nil || {}
	  config = all_config[subdomain]
		
	  if config.nil? or config['oauth'].nil? or config['oauth']['request_token'].nil? or config['oauth']['request_secret'].nil?
	    client = TwitterOAuth::Client.new(
	      :consumer_key => all_config['general']['oauth']['consumer_key'],
	      :consumer_secret => all_config['general']['oauth']['consumer_secret']
	    )

	    request_token = client.request_token

	    puts "Please open the following address in your browser to authorize this application:"
	    puts "#{request_token.authorize_url}\n"

	    puts "Enter the PIN when you have completed authorization."
	    pin = STDIN.gets.chomp

	    access_token = client.authorize(
	      request_token.token,
	      request_token.secret,
	      :oauth_verifier => pin
	    )

	    File.open(TweetsRails::Application.config.twitter_config_file, 'w') do |out|
        all_config[subdomain] = {
          'oauth' => {
            'request_token' => access_token.token,
            'request_secret' => access_token.secret
          }
        }
	      
        YAML::dump(all_config, out)
	    end
	  else
	  	puts "Skipping twitter oath setup for #{subdomain} because it exists"
	  end
	end
	
	desc 'backup_timeline', 'backup my tweets'
	def backup_timeline
	  Tweet.get_all_subdomains.each do |subdomain|
      puts "backup timeline for #{subdomain}..."
      Tweet.subdomain = subdomain
      Tweet.backup_timeline

      puts
    end
  end
  
  desc 'backup_favorite', 'backup my favorites'
  def backup_favorite
	  Tweet.get_all_subdomains.each do |subdomain|
      puts "backup favorite for #{subdomain}..."
      Tweet.subdomain = subdomain
      Tweet.backup_favorite

      puts
    end
  end
   
  desc 'backup_mention', 'backup my mentions'
  def backup_mention
	  Tweet.get_all_subdomains.each do |subdomain|
      puts "backup mention for #{subdomain}..."
      Tweet.subdomain = subdomain
      Tweet.backup_mention
      
      puts
    end
  end

  desc 'backup', 'backup all'
  def backup
	  Tweet.get_all_subdomains.each do |subdomain|
      puts "backup for #{subdomain}..."
      Tweet.subdomain = subdomain

      puts "timeline..."
      Tweet.backup_timeline
      puts "favorite..."
      Tweet.backup_favorite
      puts "mention..."
      Tweet.backup_mention
      
      puts
    end
  end
  
  desc 'stats', 'show statistics'
  def stats(subdomain = nil)
    all_subdomains = subdomain.nil? ? Tweet.get_all_subdomains : subdomain.to_a

    all_subdomains.each do |subdomain|
      puts "#{subdomain}:"

      ['tweet', 'mention', 'favorite'].each do |type|
        all_tweets = Tweet.where(:type => type, :subdomain => subdomain)

        first = all_tweets.order('posted_at ASC').first
        last = all_tweets.order('posted_at ASC').last
        count = all_tweets.order('posted_at ASC').count
        
        if count > 0
          puts <<EOF
Total number of #{type}s: #{count}
Between #{first.posted_at} and #{last.posted_at}
EOF
        end
      end
    end
    puts
  end
  
  desc 'migrate_timezone', 'migrate timezone for existing records (one-off task)'
  def migrate_timezone
    
    Tweet.find_each(:batch_size => 1000) do |t|
      t.posted_at = convert_timezone(t.posted_at)
      t.created_at = convert_timezone(t.created_at)
      t.updated_at = Time.now
      t.save
      
      puts t.id
    end
  end
  
  private
  # Update Timezone from Melbourne to UTC
  def convert_timezone(datetime)
    Time.zone = 'Australia/Melbourne'
    
    # date format: 03 Apr 2011 19:01:40
    converted = Time.zone.parse(datetime.strftime('%d %b %Y %H:%M:%S'))
    
    Time.zone = 'UTC'
    
    converted
  end
end

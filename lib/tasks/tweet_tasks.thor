class TweetTasks < Thor
  require './config/environment'

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
	def setup
	  copy_config_file
	
	  config = YAML.load_file(TweetsRails::Application.config.twitter_config_file) rescue nil || {}
		
	  if config['oauth']['request_token'].nil? or config['oauth']['request_secret'].nil?
	    client = TwitterOAuth::Client.new(
	      :consumer_key => config['oauth']['consumer_key'],
	      :consumer_secret => config['oauth']['consumer_secret']
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
	      config['oauth']['request_token'] = access_token.token
	      config['oauth']['request_secret'] = access_token.secret
	      YAML::dump(config, out)
	    end
	  else
	  	puts "Skipping twitter oath setup because it exists"
	  end
	end
	
	desc 'backup_timeline', 'backup my tweets'
	def backup_timeline
	  Tweet.backup_timeline
  end
  
  desc 'backup_favorite', 'backup my favorites'
  def backup_favorite
    Tweet.backup_favorite
  end
  
  desc 'stats', 'show statistics'
  def stats
    ['tweet', 'favorite'].each do |type|
      first = Tweet.where(:type => type).order('posted_at ASC').first
      last = Tweet.where(:type => type).order('posted_at ASC').last
      count = Tweet.where(:type => type).order('posted_at ASC').count
      puts <<EOF
Total number of #{type}s: #{count}
Between #{first.posted_at} and #{last.posted_at}
EOF
    end
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
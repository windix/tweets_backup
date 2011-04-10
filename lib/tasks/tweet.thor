class Tweet < Thor
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
end
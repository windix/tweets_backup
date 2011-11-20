class ChinaTweet
  
  attr_accessor :client, :subdomain, :authorized

  def initialize(client_name, subdomain)
    @client_name = client_name
    @subdomain = subdomain
    
    if (File.exists?(config_file_name))
      @subdomain_config = oauth_config(@subdomain)

      # overwrite oauth_china default settings
      get_client.customized_config = oauth_config('general')['oauth']

      if !@subdomain_config.nil? && @subdomain_config['access_token'] && @subdomain_config['access_secret']
        @client = get_client.load(:access_token => @subdomain_config['access_token'], 
                                  :access_token_secret => @subdomain_config['access_secret'])
        @authorized = true
      else
        @client = get_client.new
        @authorized = false
      end
    else
      # need to init config file
    end
  end
  
  def process_callback(request_token, request_secret, oauth_verifier)
    @client = get_client.new(request_token, request_secret)
    @client.authorize(:oauth_verifier => oauth_verifier)
    
    results = @client.dump
    Rails.logger.debug "results: " + results.inspect
    
    if (results[:access_token] && results[:access_token_secret])
      save_oauth_config(results)
      true
    else
      false
    end
  end

  def new_tweet(text)
    # if the new tweet is not reply to someone and not with '#nosync' hash, sync to this client
    unless text =~ /^@/ || text =~ /#nosync/
      @client.add_status(text)
      Rails.logger.debug "New tweet to #{@client_name}: '#{text}'"
    end
  end
 
  def self.get_all_clients(subdomain)
    Dir.glob(Rails.configuration.china_tweet_config_file % '*').collect do |config_filename|
      client_name = config_filename.scan(/(\w+).yml/).to_s

      client_config = YAML.load_file(config_filename)[subdomain]
      authorized = !client_config.nil? && !client_config['access_token'].nil? && !client_config['access_secret'].nil?
      
      { :name => client_name, :authorized => authorized }
    end
  end

  private
  
  def config_file_name
    Rails.configuration.china_tweet_config_file % @client_name
  end
  
  def get_client
    case @client_name
    when 'qq' then OauthChina::Qq
    when 'sina' then OauthChina::Sina
    when 'sohu' then OauthChina::Sohu
    when 'douban' then OauthChina::Douban
    when 'netease' then OauthChina::Netease
    end
  end
  
  def all_oauth_config
    @config ||= YAML.load_file(config_file_name)
  end
  
  def oauth_config(section)
    result = all_oauth_config[section]
    
    if (section == 'general')
      # TODO: generate using route
      result['oauth']['url'] = Rails.configuration.root_url % @subdomain
      result['oauth']['callback'] = "#{Rails.configuration.root_url}/syncs/%s/callback" % [@subdomain, @client_name]
    end

    result
  end
  
  def save_oauth_config(results)
    @config[@subdomain] = {
      'access_token' => results[:access_token],
      'access_secret' => results[:access_token_secret]
    }
    
    File.open(config_file_name, 'w') do |out|
      YAML::dump(@config, out)
    end
  end
end

class ChinaTweet
  
  attr_accessor :client

  def initialize(client_name)
    @client_name = client_name
    
    if (File.exists?(config_file_name))
      if oauth_config['access_token'] && oauth_config['access_secret']
        @client = get_client.load(:access_token => oauth_config['access_token'], 
                                  :access_token_secret => oauth_config['access_secret'])
      else
        @client = get_client.new
      end
    else
      # need to init config file
    end
  end
  
  def process_callback(request_token, request_secret, oauth_verifier)
    @client = get_client.new(request_token, request_secret)
    @client.authorize(:oauth_verifier => oauth_verifier)
    
    results = @client.dump
    logger.debug "results: " + results.inspect
    
    if (results[:access_token] && results[:access_token_secret])
      save_oauth_config(results)
      true
    else
      false
    end
  end
  
  def new_tweet(text)
    # if the new tweet is not reply to someone and not with '#nosync' hash, sync to this client
    @client.add_status(text) if text =~ /^@/ && !(text =~ /#nosync/)
  end
  
  private
  
  def config_file_name
    "#{Rails.root}/config/oauth/#{@client_name}.yml"
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
  
  def full_oauth_config
    @config ||= YAML.load_file(config_file_name)
  end
  
  def oauth_config
    full_oauth_config[Rails.env]
  end
  
  def save_oauth_config(results)
    File.open(config_file_name, 'w') do |out|
      oauth_config['access_token'] = results[:access_token]
      oauth_config['access_secret'] = results[:access_token_secret]
      YAML::dump(@config, out)
    end
  end
  
end

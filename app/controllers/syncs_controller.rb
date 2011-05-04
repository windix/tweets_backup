require 'yaml'

class SyncsController < ApplicationController
  def new
    # request_key and request_secret will be loaded from config/oauth/qq.yml
    client = OauthChina::Qq.new
    # oauth_token is generated based on request_key and request_secret
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to client.authorize_url
  end

  def callback
    client = OauthChina::Qq.load(Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token])))
    client.authorize(:oauth_verifier => params[:oauth_verifier])
    
    results = client.dump
    
    logger.debug results
    
    if (results[:access_token] && results[:access_token_secret])
      # oauth is successful
      # save access_token and access_token_secret
      save_oauth_config(client.name, results)
    else
      # ouath failed
      
    end
  end
  
  def test
    oauth_config = oauth_config(params[:type])
    client = OauthChina::Qq.load(:access_token => oauth_config['access_token'], :access_token_secret => oauth_config['access_secret'])
    client.add_status('Test post No.2!')
    
    render :text => 'OK!'
  end

  private

  def oauth_config(client_name)
    config = full_oauth_config(client_name)
    config[Rails.env]
  end

  def full_oauth_config(client_name)
    @config ||= YAML.load_file(config_file_name(client_name))
  end

  def save_oauth_config(client_name, results)
    full_oauth_config(client_name)
    
    File.open(config_file_name(client_name), 'w') do |out|
      @config[Rails.env]['access_token'] = results[:access_token]
      @config[Rails.env]['access_secret'] = results[:access_token_secret]
      YAML::dump(@config, out)
    end
  end

  def config_file_name(client_name)
    "#{Rails.root}/config/oauth/#{client_name}.yml"
  end

  def build_oauth_token_key(client_name, oauth_token)
    [client_name, oauth_token].join('_')
  end

end

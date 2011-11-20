require 'yaml'

class SyncsController < ApplicationController
  def setup
  end

  def new
    # request_key and request_secret will be loaded from config/oauth/qq.yml
    client = ChinaTweet.new(params[:type], @subdomain).client
    # oauth_token is generated based on request_key and request_secret
    # cache request_token.token and request_token.secret for callback
    Rails.cache.write(build_oauth_token_key(client.name, client.oauth_token), client.dump)
    redirect_to client.authorize_url
  end

  def callback
    # load saved request_token token and secret
    data = Rails.cache.read(build_oauth_token_key(params[:type], params[:oauth_token]))
    if ChinaTweet.new(params[:type], @subdomain).process_callback(data[:request_token], data[:request_token_secret], params[:oauth_verifier])
      # oauth is successful
      render :text => 'CALLBACK OK!'
    else
      # ouath failed
      render :text => 'CALLBACK FAILED!'
    end
  end
  
  def test
    client = ChinaTweet.new(params[:type], @subdomain).client
    client.add_status('Test post')
    
    render :text => 'OK!'
  end

  private

  def build_oauth_token_key(client_name, oauth_token)
    [client_name, oauth_token].join('_')
  end

end

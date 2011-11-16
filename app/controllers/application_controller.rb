class ApplicationController < ActionController::Base
  before_filter :set_subdomain

  protect_from_forgery

  def set_subdomain
    Tweet.subdomain = @subdomain = request.subdomain
  end
end

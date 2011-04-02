class TweetsController < ApplicationController
  def index
    @tweets = Tweet.where(:type => 'tweet').order('created_at ASC').first(10)
  end

end

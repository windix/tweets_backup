class TweetsController < ApplicationController
  def tweets
    get_tweets(:tweet)
  end
  
  def favorites
    get_tweets(:favorite)
  end
  
  def mentions
    get_tweets(:mention)
    render :action => "favorites"
  end
  
  private
  def get_tweets(type)
    Tweet.set_type(type)
    @tweets = Tweet.get_tweets
  
    last_page_number = Tweet.last_page_number(@tweets)

    @tweets = @tweets.page(params[:page] || last_page_number).per(Tweet.per_page)  
  end
end

class TweetsController < ApplicationController
  def index
    Tweet.set_type('tweet')
    @tweets = Tweet.get_tweets
    last_page_number = Tweet.last_page_number(@tweets)

    @tweets = @tweets.paginate(:page => params[:page] || last_page_number, :per_page => Tweet.per_page).reverse
  end
end

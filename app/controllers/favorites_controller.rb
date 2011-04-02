class FavoritesController < ApplicationController
  def index
    @tweets = Tweet.where(:type => 'favorite').order('created_at ASC').paginate(:page => params[:page], :per_page => 20)
  end

end

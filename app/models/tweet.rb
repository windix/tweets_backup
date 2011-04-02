class Tweet < ActiveRecord::Base
  self.inheritance_column = :not_in_use

  def post_date
    created_at.strftime('%Y-%m-%d')
  end

  def post_time
    created_at.strftime('%H:%M')
  end

  def self.set_type(type)
    @type = type
  end

  def self.get_tweets
    where(:type => @type).order('created_at ASC')   
  end

  def self.per_page
    20
  end

  def self.last_page_number(collections)
    total = collections.count
    [((total - 1) / per_page) + 1, 1].max
  end
end

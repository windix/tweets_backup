class Tweet < ActiveRecord::Base
  self.inheritance_column = :not_in_use

  def post_date
    created_at.strftime('%Y-%m-%d')
  end

  def post_time
    created_at.strftime('%H:%M')
  end
end

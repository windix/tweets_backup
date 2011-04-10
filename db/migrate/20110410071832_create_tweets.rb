class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string    "external_id",         :limit => 50
      t.timestamp "created_at"
      t.integer   "in_reply_to_user_id"
      t.string    "source",              :limit => 50
      t.integer   "user_id"
      t.string    "user_name",           :limit => 50
      t.string    "user_screen_name",    :limit => 50
      t.text      "text"
      t.timestamp "archived_at"
      t.text      "raw"
      t.string    "type",                :limit => 50
    end
  end

  def self.down
    drop_table :tweets
  end
end

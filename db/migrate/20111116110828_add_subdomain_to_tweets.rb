class AddSubdomainToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :subdomain, :string
    execute "UPDATE tweets SET subdomain = 'windix'"
  end

  def self.down
    remove_column :tweets, :subdomain
  end
end

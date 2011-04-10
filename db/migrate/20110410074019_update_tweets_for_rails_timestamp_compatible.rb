class UpdateTweetsForRailsTimestampCompatible < ActiveRecord::Migration
  def self.up
    change_table :tweets do |t|
      t.rename :created_at, :posted_at
      t.rename :archived_at, :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    t.rename :created_at, :archived_at
    t.rename :posted_at, :created_at
    t.remove :updated_at
  end
end

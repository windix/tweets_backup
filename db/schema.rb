# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111116110828) do

  create_table "tweets", :force => true do |t|
    t.string   "external_id",         :limit => 50
    t.datetime "posted_at"
    t.integer  "in_reply_to_user_id"
    t.string   "source",              :limit => 50
    t.integer  "user_id"
    t.string   "user_name",           :limit => 50
    t.string   "user_screen_name",    :limit => 50
    t.text     "text"
    t.datetime "created_at"
    t.text     "raw"
    t.string   "type",                :limit => 50
    t.datetime "updated_at"
    t.string   "subdomain"
  end

end

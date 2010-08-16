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

ActiveRecord::Schema.define(:version => 20100816145011) do

  create_table "accounts", :force => true do |t|
    t.string   "email",              :limit => 128
    t.string   "first_name",                                       :null => false
    t.string   "last_name",                                        :null => false
    t.string   "title",                                            :null => false
    t.string   "profile_picture"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_id"
    t.string   "gender"
    t.string   "locale"
    t.integer  "timezone"
    t.integer  "login_count",                       :default => 0, :null => false
    t.datetime "last_login"
    t.integer  "discovered_through"
  end

  add_index "accounts", ["facebook_id"], :name => "index_accounts_on_facebook_id"

  create_table "bars", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",                                                  :null => false
    t.string   "banner",                                                    :null => false
    t.string   "contact"
    t.integer  "total_plays",                                :default => 0, :null => false
    t.decimal  "total_beers", :precision => 15, :scale => 0, :default => 0, :null => false
  end

  create_table "barships", :force => true do |t|
    t.integer  "account_id",                 :null => false
    t.integer  "bar_id",                     :null => false
    t.integer  "play_count",  :default => 0, :null => false
    t.datetime "last_play"
    t.integer  "total_beers", :default => 0, :null => false
    t.integer  "max_beers",   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "barships", ["account_id"], :name => "index_barships_on_account_id"
  add_index "barships", ["bar_id"], :name => "index_barships_on_bar_id"

  create_table "friendships", :force => true do |t|
    t.integer  "account_id", :null => false
    t.integer  "friend_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["account_id"], :name => "index_friendships_on_account_id"
  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"

  create_table "replays", :force => true do |t|
    t.integer  "account_id",                                                       :null => false
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mode"
    t.string   "game_version"
    t.integer  "play_time"
    t.decimal  "avg_time_per_turn",  :precision => 10, :scale => 3
    t.integer  "total_turns"
    t.text     "replay"
    t.integer  "collected_blond"
    t.integer  "collected_brown"
    t.integer  "collected_amber"
    t.integer  "collected_food"
    t.integer  "collected_water"
    t.integer  "collected_liquor"
    t.integer  "collected_coaster"
    t.integer  "collected_tomato"
    t.integer  "max_group_size"
    t.integer  "groups_3"
    t.integer  "groups_4"
    t.integer  "groups_5"
    t.integer  "max_combo"
    t.decimal  "avg_combo",          :precision => 10, :scale => 3
    t.integer  "capa_blond_gained"
    t.integer  "capa_blond_used"
    t.integer  "capa_brown_gained"
    t.integer  "capa_brown_used"
    t.integer  "capa_amber_gained"
    t.integer  "capa_amber_used"
    t.integer  "capa_food_gained"
    t.integer  "capa_food_used"
    t.integer  "capa_water_gained"
    t.integer  "capa_water_used"
    t.integer  "capa_liquor_gained"
    t.integer  "capa_liquor_used"
    t.integer  "capa_tomato_gained"
    t.integer  "capa_tomato_used"
    t.integer  "piss_count"
    t.integer  "vomit_count"
    t.integer  "reset_count"
    t.integer  "max_piss_level"
    t.decimal  "avg_piss_level",     :precision => 10, :scale => 3
    t.integer  "max_vomit"
    t.decimal  "avg_vomit",          :precision => 10, :scale => 3
    t.integer  "invalid_moves"
    t.string   "user_agent"
    t.string   "flash_version"
    t.integer  "stack_ejected"
    t.integer  "stack_collected"
    t.string   "token"
    t.datetime "token_use_time"
    t.string   "ip"
    t.integer  "seed"
    t.boolean  "game_over"
    t.integer  "update_count",                                      :default => 0, :null => false
  end

  add_index "replays", ["account_id"], :name => "index_replays_on_account_id"

end

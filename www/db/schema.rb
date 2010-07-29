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

ActiveRecord::Schema.define(:version => 20100729142902) do

  create_table "accounts", :force => true do |t|
    t.string   "login",      :limit => 32,                 :null => false
    t.string   "password",   :limit => 32
    t.string   "email",      :limit => 128
    t.string   "first_name",                               :null => false
    t.string   "last_name",                                :null => false
    t.string   "title",                                    :null => false
    t.integer  "level",                     :default => 0, :null => false
    t.string   "avatar"
    t.integer  "play_count",                :default => 0, :null => false
    t.datetime "total_play",                               :null => false
    t.datetime "last_play"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bars", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beta_scores", :force => true do |t|
    t.integer  "account_id",                                         :null => false
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mode"
    t.string   "game_version"
    t.integer  "caps"
    t.integer  "play_time"
    t.decimal  "avg_time_per_turn",   :precision => 10, :scale => 3
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
    t.integer  "multiplier_count"
    t.integer  "max_multiplier"
    t.integer  "max_combo"
    t.decimal  "avg_combo",           :precision => 10, :scale => 3
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
    t.integer  "capa_coaster_gained"
    t.integer  "capa_coaster_used"
    t.integer  "piss_count"
    t.integer  "vomit_count"
    t.integer  "reset_count"
    t.integer  "max_piss_level"
    t.decimal  "avg_piss_level",      :precision => 10, :scale => 3
    t.integer  "max_vomit"
    t.decimal  "avg_vomit",           :precision => 10, :scale => 3
    t.integer  "invalid_moves"
    t.string   "user_agent"
    t.string   "flash_version"
  end

  create_table "scores", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "bar_id"
    t.integer  "score",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

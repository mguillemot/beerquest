class Replay
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1 # Note: required declaration to have NULLable FK
  property :bar_id, Integer, :min => 1     # Note: required declaration to have NULLable FK
  property :score, Integer
  property :mode, String
  property :game_version, String
  property :play_time, Integer
  property :avg_time_per_turn, Decimal
  property :total_turns, Integer
  property :replay, Text
  property :collected_blond, Integer
  property :collected_brown, Integer
  property :collected_amber, Integer
  property :collected_food, Integer
  property :collected_water, Integer
  property :collected_liquor, Integer
  property :collected_tomato, Integer
  property :max_group_size, Integer
  property :groups_3, Integer
  property :groups_4, Integer
  property :groups_5, Integer
  property :max_combo, Integer
  property :avg_combo, Decimal
  property :capa_blond_gained, Integer
  property :capa_blond_used, Integer
  property :capa_brown_gained, Integer
  property :capa_brown_used, Integer
  property :capa_amber_gained, Integer
  property :capa_amber_used, Integer
  property :capa_food_gained, Integer
  property :capa_food_used, Integer
  property :capa_water_gained, Integer
  property :capa_water_used, Integer
  property :capa_liquor_gained, Integer
  property :capa_liquor_used, Integer
  property :capa_tomato_gained, Integer
  property :capa_tomato_used, Integer
  property :piss_count, Integer
  property :vomit_count, Integer
  property :reset_count, Integer
  property :max_piss_level, Integer
  property :avg_piss_level, Decimal
  property :max_vomit, Integer
  property :avg_vomit, Decimal
  property :invalid_moves, Integer
  property :user_agent, String, :length => 255
  property :flash_version, String
  property :stack_ejected, Integer
  property :stack_collected, Integer
  property :token, String, :length => 32
  property :token_use_time, DateTime
  property :ip, String, :length => 15
  property :seed, Integer
  property :game_over, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :update_count, Integer, :default => 0

  belongs_to :account
  belongs_to :bar
end

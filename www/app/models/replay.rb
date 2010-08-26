class Replay
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1 # Note: required declaration to have NULLable FK
  property :bar_id, Integer, :min => 1     # Note: required declaration to have NULLable FK
  property :score, Integer
  property :mode, String, :lazy => :stats
  property :game_version, String, :lazy => :stats
  property :play_time, Integer, :lazy => :stats
  property :avg_time_per_turn, Decimal, :lazy => :stats
  property :total_turns, Integer, :lazy => :stats
  property :replay, Text, :lazy => :stats
  property :collected_blond, Integer, :lazy => :stats
  property :collected_brown, Integer, :lazy => :stats
  property :collected_amber, Integer, :lazy => :stats
  property :collected_food, Integer, :lazy => :stats
  property :collected_water, Integer, :lazy => :stats
  property :collected_liquor, Integer, :lazy => :stats
  property :collected_tomato, Integer, :lazy => :stats
  property :max_group_size, Integer, :lazy => :stats
  property :groups_3, Integer, :lazy => :stats
  property :groups_4, Integer, :lazy => :stats
  property :groups_5, Integer, :lazy => :stats
  property :max_combo, Integer, :lazy => :stats
  property :avg_combo, Decimal, :lazy => :stats
  property :capa_blond_gained, Integer, :lazy => :stats
  property :capa_blond_used, Integer, :lazy => :stats
  property :capa_brown_gained, Integer, :lazy => :stats
  property :capa_brown_used, Integer, :lazy => :stats
  property :capa_amber_gained, Integer, :lazy => :stats
  property :capa_amber_used, Integer, :lazy => :stats
  property :capa_food_gained, Integer, :lazy => :stats
  property :capa_food_used, Integer, :lazy => :stats
  property :capa_water_gained, Integer, :lazy => :stats
  property :capa_water_used, Integer, :lazy => :stats
  property :capa_liquor_gained, Integer, :lazy => :stats
  property :capa_liquor_used, Integer, :lazy => :stats
  property :capa_tomato_gained, Integer, :lazy => :stats
  property :capa_tomato_used, Integer, :lazy => :stats
  property :piss_count, Integer, :lazy => :stats
  property :vomit_count, Integer, :lazy => :stats
  property :reset_count, Integer, :lazy => :stats
  property :max_piss_level, Integer, :lazy => :stats
  property :avg_piss_level, Decimal, :lazy => :stats
  property :max_vomit, Integer, :lazy => :stats
  property :avg_vomit, Decimal, :lazy => :stats
  property :invalid_moves, Integer, :lazy => :stats
  property :stack_ejected, Integer, :lazy => :stats
  property :stack_collected, Integer, :lazy => :stats
  property :user_agent, String, :length => 255, :lazy => :stats
  property :flash_version, String, :lazy => :stats
  property :token, String, :length => 32, :lazy => :stats
  property :token_use_time, DateTime, :lazy => :stats
  property :ip, String, :length => 15, :lazy => :stats
  property :seed, Integer, :lazy => :stats
  property :game_over, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime, :lazy => :stats
  property :update_count, Integer, :default => 0, :lazy => :stats

  belongs_to :account
  belongs_to :bar

  def self.finished
    self.all(:game_over => true)
  end
end

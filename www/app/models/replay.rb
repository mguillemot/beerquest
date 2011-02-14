class Replay
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1 # Note: required declaration to have NULLable FK
  property :bar_id, Integer, :min => 1 # Note: required declaration to have NULLable FK
  property :score, Integer, :index => true
  property :mode, String, :required => true # solo, vs
  property :game_version, String
  property :play_time, Integer
  property :avg_time_per_turn, Decimal, :precision => 20, :scale => 10 # Note: need big precision to pass validaitons
  property :total_turns, Integer
  property :replay, Text
  property :message, Text, :length => 160
  property :validator, String, :length => 40
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
  property :avg_combo, Decimal, :precision => 20, :scale => 10
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
  property :avg_piss_level, Decimal, :precision => 20, :scale => 10
  property :max_vomit, Integer
  property :avg_vomit, Decimal, :precision => 20, :scale => 10
  property :invalid_moves, Integer
  property :stack_ejected, Integer
  property :stack_collected, Integer
  property :user_agent, String, :length => 255
  property :flash_version, String
  property :token, String, :length => 32, :required => true
  property :token_use_time, DateTime
  property :ip, String, :length => 15, :required => true
  property :seed, Integer
  property :game_over, Boolean, :required => true, :default => false, :index => true
  property :created_at, DateTime, :index => true
  property :updated_at, DateTime
  property :update_count, Integer, :default => 0, :required => true

  belongs_to :account
  belongs_to :bar

  def self.finished
    self.all(:game_over => true)
  end

  def self.extract_friends_scores_of(account)
    friend_ids = account.friends.map { |f| f.id }
    friend_ids << account.id
    min_date = DateTime.now - 2.weeks
    raw      = repository(:default).adapter.select "SELECT account_id, MAX(score) AS score
                                                FROM replays
                                                WHERE game_over = 1
                                                  AND created_at >= '#{min_date}'
                                                  AND account_id IN (#{friend_ids.join(',')})
                                                GROUP BY account_id
                                                ORDER BY score DESC;"
    accounts = Account.all(:id => friend_ids).inject({}) do |accs, acc|
      accs[acc.id] = acc
      accs
    end
    scores = []
    raw.each do |r|
      acc = accounts[r.account_id]
      scores << {:rank => scores.length + 1, :account_id => acc.id, :profile_picture => acc.profile_picture, :name => acc.display_name, :score => r.score}
    end
    scores
  end

  def self.extract_bar_scores_of(bar)
    min_date = DateTime.now - 2.weeks
    raw      = repository(:default).adapter.select "SELECT account_id, MAX(score) AS score
                                                FROM replays
                                                WHERE game_over = 1
                                                  AND created_at >= '#{min_date}'
                                                  AND bar_id = #{bar.id}
                                                GROUP BY account_id
                                                ORDER BY score DESC;"
    client_ids = raw.map { |r| r.account_id }
    accounts = bar.accounts.inject({}) do |accs, acc|
      accs[acc.id] = acc
      accs
    end
    scores = []
    raw.each do |r|
      acc = accounts[r.account_id]
      scores << {:rank => scores.length + 1, :account_id => acc.id, :profile_picture => acc.profile_picture, :name => acc.display_name, :score => r.score}
    end
    scores
  end

end

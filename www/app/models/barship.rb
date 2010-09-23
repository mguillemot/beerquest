class Barship
  include DataMapper::Resource

  property :account_id, Integer, :min => 1, :key => true # Note 1: these 2 properties are necessary besides the belongs_to declarations to declare the composite key
  property :bar_id, Integer, :min => 1, :key => true     # Note 2: :min => 1 is necessary to have UNSIGNED INT to reference the column as FK
  property :favorite, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :bar

  # TODO
  def weekly_beers
    0
  end

  # TODO
  def best_rank
    1
  end

  # TODO
  def best_rank_date
    DateTime.now
  end

  def play_count
    Replay.all(:bar => bar, :account => account, :game_over => true).count
  end

  def total_beers
    Replay.all(:bar => bar, :account => account, :game_over => true).sum(:score)
  end

  def max_score
    Replay.all(:bar => bar, :account => account, :game_over => true).max(:score)
  end
end

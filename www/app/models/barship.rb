class Barship
  include DataMapper::Resource

  property :account_id, Integer, :min => 1, :key => true # Note 1: these 2 properties are necessary besides the belongs_to declarations to declare the composite key
  property :bar_id, Integer, :min => 1, :key => true     # Note 2: :min => 1 is necessary to have UNSIGNED INT to reference the column as FK
  property :favorite, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :bar

  def weekly_beers
    weekly_completed_replays.sum(:score) || 0
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
    all_completed_replays.count
  end

  def total_beers
    all_completed_replays.sum(:score) || 0
  end

  def max_score
    all_completed_replays.max(:score) || 0
  end

  protected

  def all_completed_replays
    Replay.all(:bar => bar, :account => account, :game_over => true)
  end

  def weekly_completed_replays
    Replay.all(:bar => bar, :account => account, :game_over => true, :created_at.gte => DateTime.now - 2.weeks)
  end

end

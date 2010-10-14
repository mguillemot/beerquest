class Bar
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :length => 100, :required => true
  property :url, String, :length => 1024, :required => true
  property :rss, String, :length => 1024
  property :banner, String, :length => 1024, :required => true
  property :contact, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :barships, :constraint => :destroy
  has n, :replays, :constraint => :set_nil

  def self.default_bar
    self.get!(1)
  end

  def total_members
    barships.count
  end
  
  def active_members
    barships.count(:updated_at.gte => DateTime.now - 1.week)
  end

  # TODO
  def new_active_members
    0
  end

  def total_beers
    replays.sum(:score) || 0
  end

  def weekly_beers
    replays.all(:created_at.gte => DateTime.now - 1.week).sum(:score) || 0
  end

  # TODO
  def rank
    1
  end

  def always_high_scores
    extract_scores(replays.all(:game_over => true, :order => :score.desc))
  end

  def always_high_score_for(account)
    best_replay = replays.first(:game_over => true, :account_id => account.id, :order => :score.desc)
    best_replay ? best_replay.score : 0
  end

  def weekly_high_scores
    extract_scores(weekly_replays.all(:game_over => true, :order => :score.desc))
  end

  def weekly_high_score_for(account)
    best_replay = weekly_replays.first(:game_over => true, :account_id => account.id, :order => :score.desc)
    best_replay ? best_replay.score : 0
  end

  def weekly_replays
    replays.all(:created_at.gte => DateTime.now - 1.week)
  end

  def weekly_scores
    weekly_high_scores[0..4]
  end

  def weekly_scores_for(account)
    scores_for(weekly_high_scores, account)
  end

  def total_scores
    always_high_scores[0..4]
  end

  def total_scores_for(account)
    scores_for(always_high_scores, account)
  end

  private

  def scores_for(score_list, account)
    n = score_list.length
    i = score_list.find_index { |score| score[:account_id] == account.id }
    if i
      a = 2
      b = 2
      if i == 0
        a -= 2
        b += 2
      elsif i == 1
        a -= 1
        b += 1
      elsif i == n-1
        a += 2
        b -= 2
      elsif i == n-2
        a += 1
        b -= 1
      end
      score_list[[i-a, 0].max .. [i+b, n-1].min]
    else
      score_list[-5 .. -1]
    end
  end
  
  def extract_scores(source)
    scores = []
    scorers = {}
    source.each do |replay|
      unless scorers[replay.account_id]
        scores << {:rank => scores.length+1, :account_id => replay.account_id, :full_name => replay.account.full_name, :profile_picture => replay.account.profile_picture, :score => replay.score}
        scorers[replay.account_id] = true
      end
    end
    scores
  end
end

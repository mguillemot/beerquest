class Bar
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :length => 100, :required => true
  property :url, String, :length => 1024, :required => true
  property :rss_fr, String, :length => 1024
  property :rss_en, String, :length => 1024
  property :banner_big, String, :length => 1024, :required => true
  property :banner_small, String, :length => 1024, :required => true
  property :contact, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :barships, :constraint => :destroy
  has n, :replays, :constraint => :set_nil

  def self.default_bar
    self.get!(1)
  end

  def rss
    attribute_get("rss_#{I18n.locale}") || rss_en
  end

  def total_members
    barships.count
  end

  def active_members
    barships.count(:updated_at.gte => DateTime.now - 1.week)
  end

  def new_active_members
    barships.count(:created_at.gte => DateTime.now - 1.week)
  end

  def total_beers
    complete_replays.sum(:score) || 0
  end

  def weekly_beers
    weekly_complete_replays.sum(:score) || 0
  end

  def rank
    all_bars = Bar.all.sort_by { |b| -b.total_beers }
    all_bars.each_with_index do |b, i|
      return (i + 1) if b == self
    end
    0
  end

  def always_high_score
    complete_replays.max(:score) || 0
  end

  def always_high_score_for(account)
    complete_replays.all(:account_id => account.id).max(:score) || 0
  end

  def weekly_high_score
    weekly_complete_replays.max(:score) || 0
  end

  def weekly_high_score_for(account)
    weekly_complete_replays.all(:account_id => account.id).max(:score) || 0
  end

  def weekly_top_scores
    weekly_high_scores[0..4]
  end

  def weekly_centered_scores_for(account)
    scores_for(weekly_high_scores, account)
  end

  def total_top_scores
    always_high_scores[0..4]
  end

  def total_centered_scores_for(account)
    scores_for(always_high_scores, account)
  end

  def messages
    complete_replays.all(:order => :created_at.desc, :limit => 20, :message.not => nil)
  end

  private

  def complete_replays
    replays.all(:game_over => true)
  end

  def weekly_complete_replays
    complete_replays.all(:created_at.gte => DateTime.now - 1.week)
  end

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
    scores  = []
    scorers = {}
    source.each do |replay|
      unless scorers[replay.account_id]
        scores << {:rank => scores.length+1, :account_id => replay.account_id, :full_name => replay.account.full_name, :profile_picture => replay.account.profile_picture, :score => replay.score}
        scorers[replay.account_id] = true
      end
    end
    scores
  end

  def always_high_scores
    extract_scores(complete_replays.all(:game_over => true, :order => :score.desc))
  end

  def weekly_high_scores
    extract_scores(weekly_complete_replays.all(:game_over => true, :order => :score.desc))
  end


end

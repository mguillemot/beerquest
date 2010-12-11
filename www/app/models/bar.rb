class Bar
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :length => 100, :required => true
  property :turns, Integer, :min => 0, :default => Game::Constants::DEFAULT_INITIAL_TURNS, :required => true
  property :url, String, :length => 1024, :required => true
  property :rss_fr, String, :length => 1024
  property :rss_en, String, :length => 1024
  property :banner_big, String, :length => 1024, :required => true
  property :banner_small, String, :length => 1024, :required => true
  property :contact, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :barships, :constraint => :destroy
  has n, :accounts, :through => :barships
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
    barships.count(:updated_at.gte => DateTime.now - 2.weeks)
  end

  def new_active_members
    barships.count(:created_at.gte => DateTime.now - 2.weeks)
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
    return @weekly_top_scores if @weekly_top_scores
    @weekly_top_scores = Replay.extract_bar_scores_of(self)[0...30]
  end

  def messages
    complete_replays.all(:order => :created_at.desc, :limit => 20) #, :message.not => nil)
  end

  private

  def complete_replays
    replays.all(:game_over => true)
  end

  def weekly_complete_replays
    complete_replays.all(:created_at.gte => DateTime.now - 2.weeks)
  end

end

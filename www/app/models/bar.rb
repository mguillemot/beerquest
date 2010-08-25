class Bar
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :url, String, :required => true
  property :rss, String
  property :banner, String, :required => true
  property :contact, String
  property :total_plays, Integer, :required => true, :default => 0
  property :total_beers, Integer, :required => true, :default => 0
  property :weekly_plays, Integer, :required => true, :default => 0
  property :weekly_beers, Integer, :required => true, :default => 0
  property :total_members, Integer, :required => true, :default => 0
  property :active_members, Integer, :required => true, :default => 0
  property :weekly_new_active_members, Integer, :required => true, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :barships, :constraint => :destroy
  has n, :replays, :constraint => :destroy

  def weekly_scores
    []
  end

  def weekly_scores_for(account)
    []
  end

  def total_scores
    []
  end

  def total_scores_for(account)
    []
  end
end

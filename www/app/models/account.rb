class Account
  include DataMapper::Resource

  property :id, Serial
  property :first_name, String
  property :last_name, String
  property :profile_picture, String
  property :gender, String
  property :locale, String
  property :timezone, Integer
  property :discovered_through, Integer
  property :facebook_id, Integer, :min => 0, :max => 2**64-1
  property :login_count, Integer, :default => 0
  property :last_login, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :friendships, :constraint => :destroy
  has n, :friends, :model => Account, :through => :friendships, :via => :friend
  has n, :barships, :constraint => :destroy
  has n, :favorite_bars, :model => Bar, :through => :barships, :via => :bar
  has n, :replays, :constraint => :set_nil

  def full_name
    "#{first_name} #{last_name}"
  end

  def last_bar
    last_barship = barships.first(:order => :updated_at.desc)
    last_barship ? last_barship.bar : Bar.default_bar
  end

  def total_beers
    completed_games.sum(:score) || 0
  end

  def best_score_weekly
    weekly_completed_games.max(:score) || 0
  end

  def profile_picture
    attribute_get(:profile_picture) || "http://static.ak.fbcdn.net/rsrc.php/z1LUW/hash/eu00g0eh.gif"
  end

  private

  def completed_games
    replays.all(:game_over => true)
  end

  def weekly_completed_games
    completed_games.all(:created_at.gte => DateTime.now - 1.week)
  end


end

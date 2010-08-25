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
  property :login_count, Integer, :required => true, :default => 0
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

  def total_beers
    barships.sum(:total_beers)
  end

  def max_beers
    barships.maximum(:max_beers)
  end

  def play_count
    barships.sum(:play_count)
  end

  def last_bar
    barships.first(:order => :updated_at.desc).bar
  end
end

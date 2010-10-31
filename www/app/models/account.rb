class Account
  include DataMapper::Resource

  property :id, Serial
  property :first_name, String, :length => 255, :required => true
  property :last_name, String, :length => 255, :required => true
  property :profile_picture, String, :length => 255
  property :gender, String
  property :locale, String
  property :timezone, Integer
  property :discovered_through, Integer
  property :facebook_id, Integer, :min => 0, :max => 2**64-1, :index => true
  property :login_count, Integer, :required => true, :default => 0
  property :last_login, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :friendships, :constraint => :destroy
  has n, :friends, :model => Account, :through => :friendships, :via => :friend
  has n, :barships, :constraint => :destroy
  has n, :favorite_bars, :model => Bar, :through => :barships, :via => :bar
  has n, :replays, :constraint => :set_nil
  has n, :challenges, :constraint => :destroy
  has n, :sent_challenges, :model => Challenge, :child_key => :sent_by_id, :constraint => :destroy
  has n, :donations, :constraint => :set_nil

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

  def best_score_weekly_in_bar(bar)
    weekly_completed_games_in_bar(bar).max(:score) || 0
  end

  def profile_picture
    attribute_get(:profile_picture) || "http://static.ak.fbcdn.net/rsrc.php/z1LUW/hash/eu00g0eh.gif"
    # TODO héberger asset & gaffe que c'est une icône de femme celle-ci
  end

  def current_challenges
    challenges.all(:status => Challenge::STATUS[:pending], :parent.not => nil) + sent_challenges.all(:status => Challenge::STATUS[:pending], :parent.not => nil)
  end

  def new_received_challenges
    challenges.all(:status => Challenge::STATUS[:pending], :parent => nil)
  end

  def new_sent_challenges
    sent_challenges.all(:status => Challenge::STATUS[:pending], :parent => nil)
  end

  def already_challenging_people
    challenging = challenges.all(:status => Challenge::STATUS[:pending]).collect { |c| c.sent_by }
    challenged = sent_challenges.all(:status => Challenge::STATUS[:pending]).collect { |c| c.account }
    challenging + challenged
  end

  def victory_points
    sent_challenges.count(:status => Challenge::STATUS[:lost])
  end

  def defeat_points
    challenges.count(:status => Challenge::STATUS[:lost])
  end

  private

  def completed_games
    replays.all(:game_over => true)
  end

  def weekly_completed_games
    completed_games.all(:created_at.gte => DateTime.now - 1.week)
  end

  def completed_games_in_bar(bar)
    completed_games.all(:bar => bar)
  end

  def weekly_completed_games_in_bar(bar)
    weekly_completed_games.all(:bar => bar)
  end

end

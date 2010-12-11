class Account
  include DataMapper::Resource

  property :id, Serial
  property :facebook_id, Integer, :min => 0, :max => 2**64-1, :unique_index => true
  property :first_name, String, :length => 255, :required => true
  property :full_name, String, :length => 255, :required => true
  property :gender, String
  property :locale, String
  property :timezone, Integer
  property :nonplaying_friends, Text
  property :discovered_through, Integer
  property :login_count, Integer, :required => true, :default => 0
  property :first_login, DateTime
  property :last_login, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :friendships, :constraint => :destroy
  has n, :friends, :model => Account, :through => :friendships, :via => :friend
  has n, :barships, :constraint => :destroy
  has n, :favorite_bars, :model => Bar, :through => :barships, :via => :bar
  has n, :replays, :constraint => :set_nil
  has n, :donations, :constraint => :set_nil

  def profile_picture
    "http://graph.facebook.com/#{facebook_id}/picture"
  end

  def last_bar
    # TODO updater les barships pour savoir lequel est le VRAI last
    last_barship = barships.first(:order => :updated_at.desc)
    last_barship ? last_barship.bar : Bar.default_bar
  end

  def total_beers
    completed_games.sum(:score) || 0
  end

  def best_score_always
    completed_games.max(:score) || 0
  end

  def best_score_weekly
    weekly_completed_games.max(:score) || 0
  end

  def best_score_weekly_in_bar(bar)
    weekly_completed_games_in_bar(bar).max(:score) || 0
  end

  def already_invited_friends_fbids
    # TODO ajouter les amis déjà invités mais qui ne jouent pas encore
    # TODO enlever les amis qui jouent déjà mais qui ont un weekly_top à 0
    friends.map { |f| f.facebook_id }
  end

  def total_score_with(friend)
    replays_with(friend).inject(0) { |sum, replay| sum + replay.score }
  end

  def update_fb_dashboard_count!
    # TODO réactiver d'une autre manière quand ça sera pertinent
    -1
#    if facebook_id
#      count = pending_challenges.count
#      MiniFB.call(BeerQuest::FB_API_KEY, BeerQuest::FB_SECRET, 'dashboard.setCount', 'uid' => facebook_id, 'count' => count)
#      count
#    end
  rescue
    # Not so important, after all...
    -1
  end

  def weekly_friends_scores
    return @weekly_friends_scores if @weekly_friends_scores
    @weekly_friends_scores = Replay.extract_friends_scores_of(self)
  end

  private

  def completed_games
    replays.all(:game_over => true)
  end

  def weekly_completed_games
    completed_games.all(:created_at.gte => DateTime.now - 2.weeks)
  end

  def completed_games_in_bar(bar)
    completed_games.all(:bar => bar)
  end

  def weekly_completed_games_in_bar(bar)
    weekly_completed_games.all(:bar => bar)
  end

end

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
  has n, :challenges, :constraint => :destroy
  has n, :sent_challenges, :model => Challenge, :child_key => :sent_by_id, :constraint => :destroy
  has n, :donations, :constraint => :set_nil

  def profile_picture
    "http://graph.facebook.com/#{facebook_id}/picture"
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

  def current_challenges
    pending_challenges + pending_sent_challenges.all(:parent.not => nil)
  end

  def pending_challenges_count
    pending_challenges.size
  end

  def new_sent_challenges
    pending_sent_challenges.all(:parent => nil)
  end

  def already_invited_friends_fbids
    # TODO ajouter les amis déjà invités mais qui ne jouent pas encore
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
    Replay.extract_friends_scores_of(self)
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

  def replays_with(friend)
    result = []
    completed_games.all(:mode => 'vs').each { |r| result.push(r) if r.challenge.sent_by == friend }
    result
  end

  def pending_challenges
    challenges.all(:status => Challenge::STATUS_PENDING)
  end

  def pending_sent_challenges
    sent_challenges.all(:status => Challenge::STATUS_PENDING)
  end

  def challenges_with(friend)
    challenges.all(:sent_by => friend)
  end

  def sent_challenges_with(friend)
    sent_challenges.all(:account => friend)
  end

end

class Account
  include DataMapper::Resource

  property :id, Serial
  property :facebook_id, Integer, :min => 0, :max => 2**64-1, :unique_index => true
  property :full_name, String, :length => 255, :required => true
  property :gender, String
  property :locale, String
  property :timezone, Integer
  property :discovered_through, Integer
  property :friends, Text
  property :login_count, Integer, :required => true, :default => 0
  property :last_login, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

#  has n, :friendships, :constraint => :destroy
#  has n, :friends, :model => Account, :through => :friendships, :via => :friend
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
    res = []
    pending_challenges.all(:parent.not => nil).each { |c| res.push(c) }
    pending_sent_challenges.all(:parent.not => nil).each { |c| res.push(c) }
    res
  end

  def new_received_challenges
    pending_challenges.all(:parent => nil)
  end

  def new_sent_challenges
    pending_sent_challenges.all(:parent => nil)
  end

  def already_challenging_people
    challenging = pending_challenges.collect { |c| c.sent_by }
    challenged  = pending_sent_challenges.collect { |c| c.account }
    challenging + challenged
  end

  def total_rounds
    challenges.count(:status => [Challenge::STATUS_WON, Challenge::STATUS_LOST]) +
            sent_challenges.count(:status => [Challenge::STATUS_WON, Challenge::STATUS_LOST])
  end

  def total_rounds_with(friend)
    challenges_with(friend).count(:status => [Challenge::STATUS_WON, Challenge::STATUS_LOST]) +
            sent_challenges_with(friend).count(:status => [Challenge::STATUS_WON, Challenge::STATUS_LOST])
  end

  def total_victories
    sent_challenges.count(:status => Challenge::STATUS_LOST)
  end

  def total_victories_with(friend)
    sent_challenges_with(friend).count(:status => Challenge::STATUS_LOST)
  end

  def total_defeats
    challenges.count(:status => Challenge::STATUS_LOST)
  end

  def total_defeats_with(friend)
    challenges_with(friend).count(:status => Challenge::STATUS_LOST)
  end

  def total_score_challenge
    challenges.all(:status => [Challenge::STATUS_WON, Challenge::STATUS_LOST]).inject(0) { |sum, c| sum + (c.main_replay ? c.main_replay.score : 0) }
  end

  def total_score_with(friend)
    replays_with(friend).inject(0) { |sum, replay| sum + replay.score }
  end

  def total_challenges
    challenges.count(:parent => nil, :status => [Challenge::STATUS_WON, Challenge::STATUS_LOST]) +
            sent_challenges.count(:parent => nil, :status => [Challenge::STATUS_WON, Challenge::STATUS_LOST])
  end

  def be_challenged!(from_account)
    if challenges_with(from_account).count(:status => Challenge::STATUS_PENDING) > 0
      false
    else
      challenges.create(:sent_by => from_account, :required_score => Challenge::INITIAL_CHALLENGE)
      update_fb_dashboard_count!
      true
    end
  end

  def update_fb_dashboard_count!
    if facebook_id
      count = pending_challenges.count
      MiniFB.call(BeerQuest::FB_API_KEY, BeerQuest::FB_SECRET, 'dashboard.setCount', 'uid' => facebook_id, 'count' => count)
      count
    end
  rescue
    # Not so important, after all...
    -1
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

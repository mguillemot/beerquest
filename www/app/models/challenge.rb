class Challenge
  include DataMapper::Resource

  INITIAL_CHALLENGE = 100
  PENDING_EXPIRATION = 1.week
  ACCEPT_EXPIRATION = 2.hour
  RAISE_VALUES = [1, 3, 5, 10, 15, 20]

  STATUS_PENDING = 'pending'
  STATUS_ACCEPTED = 'accepted'
  STATUS_EXPIRED = 'expired'
  STATUS_WON = 'won'
  STATUS_LOST = 'lost'

  property :id, Serial
  property :parent_id, Integer, :min => 1, :index => true
  property :account_id, Integer, :min => 1, :required => true, :index => true
  property :sent_by_id, Integer, :min => 1, :required => true, :index => true
  property :status, String, :default => STATUS_PENDING, :required => true, :index => true
  property :required_score, Integer, :required => true
  property :score_raise, Integer
  property :accepted_at, DateTime
  property :ended_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :parent, :model => Challenge, :required => false
  belongs_to :account
  belongs_to :sent_by, :model => Account
  has 1, :child, :model => Challenge, :child_key => :parent_id, :constraint => :destroy
  has 1, :replay, :constraint => :set_nil

  def self.to_expire
    all(:status => STATUS_PENDING, :created_at.lte => DateTime.now - PENDING_EXPIRATION) + all(:status => STATUS_ACCEPTED, :accepted_at.lte => DateTime.now - ACCEPT_EXPIRATION)
  end

  def new_challenge?
    (parent == nil)
  end

  def round
    r,p = 1,parent
    while p
      r,p = (r+1),p.parent
    end
    r
  end

  def target_score
    required_score + (score_raise || 0)
  end

  def accept!(score_raise)
    score_raise = score_raise.to_i
    if status != STATUS_PENDING
      raise "cannot accept a challenge with status '#{status}'"
    end
    if expirable?
      raise "cannot accept expired challenge"
    end
    unless RAISE_VALUES.include?(score_raise)
      raise "invalid raise value: #{score_raise}"
    end
    self.status = STATUS_ACCEPTED
    self.score_raise = score_raise
    self.accepted_at = DateTime.now
    save
  end

  def end!(score)
    if status != STATUS_ACCEPTED
      raise "cannot end a challenge with status '#{status}'"
    end
    if expirable?
      raise "cannot end expired challenge"
    end
    if score >= target_score
      self.status = STATUS_WON
      Challenge.create(:account_id => sent_by_id, :sent_by_id => account_id, :required_score => target_score, :parent_id => id)
    else
      self.status = STATUS_LOST
    end
    self.ended_at = DateTime.now
    save
  end

  def expire!
    if !expirable?
      raise "challenge is not expirable"
    end
    self.status = STATUS_EXPIRED
    self.ended_at = DateTime.now
    save
  end

  private

  def expirable?
    (status == STATUS_PENDING && created_at + PENDING_EXPIRATION < DateTime.now) || (status == STATUS_ACCEPTED && accepted_at + ACCEPT_EXPIRATION < DateTime.now)
  end

end

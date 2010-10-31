class Challenge
  include DataMapper::Resource

  PENDING_EXPIRATION = 1.week
  ACCEPT_EXPIRATION = 2.hour
  RAISE_VALUES = [1, 3, 5, 10, 15, 20]
  STATUS = {
      :pending => 'pending',
      :accepted => 'accepted',
      :expired => 'expired',
      :won => 'won',
      :lost => 'lost'
  }

  property :id, Serial
  is :tree, :order => :created_at # parent_id
  property :account_id, Integer, :min => 1, :required => true
  property :sent_by_id, Integer, :min => 1, :required => true
  property :status, String, :default => STATUS[:pending], :required => true, :index => true
  property :required_score, Integer, :required => true
  property :raise, Integer
  property :accepted_at, DateTime
  property :ended_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :sent_by, :model => Account
  has 1, :replay, :constraint => :set_nil

  def self.to_expire
    all(:status => STATUS[:pending], :created_at.lte => DateTime.now - PENDING_EXPIRATION) + all(:status => STATUS[:accepted], :accepted_at.lte => DateTime.now - ACCEPT_EXPIRATION)
  end

  def new?
    (parent_id == nil)
  end

  def target_score
    required_score + (raise || 0)
  end

  def accept!(raise)
    if status != STATUS[:pending]
      raise "cannot accept a challenge with status '#{status}'"
    end
    if expirable?
      raise "cannot accept expired challenge"
    end
    unless RAISE_VALUES.include?(raise)
      raise "invalid raise value: #{raise}"
    end
    self.status = STATUS[:accepted]
    self.raise = raise
    self.accepted_at = DateTime.now
    save
  end

  def end!(score)
    if status != STATUS[:accepted]
      raise "cannot end a challenge with status '#{status}'"
    end
    if expirable?
      raise "cannot end expired challenge"
    end
    if score >= target_score
      self.status = STATUS[:won]
      Challenge.create(:account_id => sent_by_id, :sent_by_id => account_id, :required_score => target_score, :parent_id => id)
    else
      self.status = STATUS[:lost]
    end
    self.ended_at = DateTime.now
    save
  end

  def expire!
    if !expirable?
      raise "challenge is not expirable"
    end
    self.status = STATUS[:expired]
    self.ended_at = DateTime.now
    save
  end

  private

  def expirable?
    (status == STATUS[:pending] && created_at + PENDING_EXPIRATION < DateTime.now) || (status == STATUS[:accepted] && accepted_at + ACCEPT_EXPIRATION < DateTime.now)
  end

end

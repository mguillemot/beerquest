class Challenge
  include DataMapper::Resource

  property :id, Serial
  is :tree, :order => :created_at # parent_id
  property :account_id, Integer, :min => 1, :required => true
  property :sent_by_id, Integer, :min => 1, :required => true
  property :status, String, :default => 'pending', :required => true, :index => true # pending, accepted, won, lost, expired
  property :required_score, Integer, :required => true
  property :raise, Integer
  property :accepted_at, DateTime
  property :ended_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :sent_by, :model => Account
  has 1, :replay, :constraint => :set_nil

  def new?
    (parent_id == nil)
  end

  def expired?
    (created_at + 1.week < DateTime.now)
  end

  def target_score
    required_score + (raise || 0)
  end

  def accept!(raise)
    if status != 'pending'
      raise "cannot accept a challenge with status '#{status}'"
    end
    if expired?
      raise "cannot accept expired challenge"
    end
    unless [1, 3, 5, 10, 15, 20].include?(raise)
      raise "invalid raise value: #{raise}"
    end
    status = 'accepted'
    raise = raise
    accepted_at = DateTime.now
    save
  end

  def end!(score)
    if status != 'accepted'
      raise "cannot end a challenge with status '#{status}'"
    end
    if expired?
      raise "cannot end expired challenge"
    end
    if score >= target_score
      status = 'won'
      Challenge.create(:account_id => sent_by_id, :sent_by_id => account_id, :required_score => target_score, :parent_id => id)
    else
      status = 'lost'
    end
    ended_at = DateTime.now
    save
  end

end

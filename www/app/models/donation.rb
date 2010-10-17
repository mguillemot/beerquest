class Donation
  include DataMapper::Resource

  DONATIONS = {
          1 => {:amount => 0.42, :name => 'support_us.offers.offer1.name'},
          2 => {:amount => 1.5, :name => 'support_us.offers.offer2.name'},
          3 => {:amount => 3, :name => 'support_us.offers.offer3.name'},
          4 => {:amount => 5, :name => 'support_us.offers.offer4.name'},
          5 => {:amount => 10, :name => 'support_us.offers.offer5.name'},
          6 => {:amount => 100, :name => 'support_us.offers.offer6.name'}
  }

  property :id, Serial
  property :account_id, Integer, :min => 1
  property :level, Integer
  property :paypal_email, String
  property :paypal_name, String
  property :paypal_amount, Decimal, :precision => 20, :scale => 10
  property :paypal_currency, String
  property :paypal_payer_id, String
  property :paypal_correlation_id, String
  property :paypal_token, String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

  def self.total
    sum(:paypal_amount) || 0
  end

  def amount
    DONATIONS[level][:amount]
  end

  def currency
    'EUR'
  end

  def name
    key = DONATIONS[level][:name]
    I18n.t(key)
  end

  def description
    I18n.t('support_us.donation')
  end

end

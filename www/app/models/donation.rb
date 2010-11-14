class Donation
  include DataMapper::Resource

  DONATIONS = {
          1 => {:amount => 0.42, :name => 'support_us.offers.offer1.name', :volume => 0.02},
          2 => {:amount => 1.5, :name => 'support_us.offers.offer2.name', :volume => 0.25},
          3 => {:amount => 3, :name => 'support_us.offers.offer3.name', :volume => 0.50},
          4 => {:amount => 5, :name => 'support_us.offers.offer4.name', :volume => 0.33},
          5 => {:amount => 10, :name => 'support_us.offers.offer5.name', :volume => 2.00},
          6 => {:amount => 100, :name => 'support_us.offers.offer6.name', :volume => 20.00}
  }

  STATUS_PENDING = 'pending'
  STATUS_AUTHORIZED = 'authorized'
  STATUS_OK = 'ok'

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
  property :status, String, :default => STATUS_PENDING
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

  def self.total_volume
    DONATIONS.to_a.reduce(0) do |s, dtype|
      s + self.count(:level => dtype[0]) * dtype[1][:volume]
    end
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

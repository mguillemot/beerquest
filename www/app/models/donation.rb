class Donation
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1
  property :level, Integer
  property :paypal_email, String
  property :paypal_name, String
  property :paypal_amount, Decimal
  property :paypal_currency, String
  property :paypal_payer_id, String
  property :paypal_correlation_id, String
  property :paypal_token, String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

  def name
    "Grosse chope"
  end

  def description
    "Donation BeerQuest"
  end

end

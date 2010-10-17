class Donation
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1
  property :level, Integer
  property :amount, Decimal
  property :currency, String
  property :paypal_transaction_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

end

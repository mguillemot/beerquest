class Barship < ActiveRecord::Base
  belongs_to :account
  belongs_to :bar
end

class Friendship < ActiveRecord::Base
  belongs_to :account
  belongs_to :friends, :class_name => "Account"
end

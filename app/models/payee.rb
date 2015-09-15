class Payee < ActiveRecord::Base
  has_many :accounts, as: :source
  has_many :events, through: :accounts
end

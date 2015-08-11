class Account < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :event

  has_many :account_transactions
  has_many :entries, foreign_key: "parent_id"

end

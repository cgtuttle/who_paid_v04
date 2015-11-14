class Account < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :event

  has_many :account_transactions
  has_many :allocations

# Journal relationships
  has_many :payments_paid, class_name: "Payment", foreign_key: :account_from
  has_many :payments_received, class_name: "Payment", foreign_key: :account_to

end

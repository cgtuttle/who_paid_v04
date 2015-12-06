class Account < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :event

  has_many :account_transactions
  has_many :allocations
  has_many :payments, through: :allocations

# Journal relationships
  has_many :payments_paid, class_name: "Payment", foreign_key: :account_from
  has_many :payments_received, class_name: "Payment", foreign_key: :account_to

  scope :user, -> { joins("join users on users.id = accounts.source_id").where(source_type: "User").order("users.last_name") }

  def self.people
    Account.user + Account.where(source_type: "User", source_id: nil).sort_by(&:last_name)
  end

  def self.available_for_payment(payment)
    where(source_type: "User") - payment.accounts
  end

  def balance
  	self.account_transactions.sum(:credit) - self.account_transactions.sum(:debit)
  end

  def first_name
    self.account_name.split[0]
  end

  def last_name
    self.account_name.split[1] || self.account_name
  end

end

class Account < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :event

  has_many :account_transactions
  has_many :allocations
  has_many :payments, through: :allocations, source: :journal, source_type: "Payment"

# Journal relationships
  has_many :payments_paid, foreign_key: :account_from, class_name: "Payment"
  has_many :payments_received, foreign_key: :account_to, class_name: "Payment"

  scope :current_event, ->(event_id) { where( event_id: event_id )}
  scope :user, -> { joins("join users on users.id = accounts.source_id").where(source_type: "User", inactive: false).order("users.last_name") }

  def self.people
    Account.user + Account.where(source_type: "User", source_id: nil).sort_by(&:last_name)
  end

  def self.available_for_payment(payment)
    where(source_type: "User") - payment.accounts
  end

  def balance
  	self.account_transactions.not_reversed.sum(:credit) - self.account_transactions.not_reversed.sum(:debit)
  end

  def owes?
    self.balance < 0
  end

  def statement_transactions
    self.account_transactions.not_reversed.includes(:journal).order(:occurred_on, :created_at)
  end

  def first_name
    self.account_name.split[0] if self.account_name
  end

  def last_name
    (self.account_name.split[1] || self.account_name) if self.account_name
  end

  def update_default_method(new_method)
    self.default_method = new_method
    self.save
  end

  def update_default_share(share)
    puts "self.id = #{self.id}, self.default_share = #{share}"
    self.default_share = share
    self.save
  end

end

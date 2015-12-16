class Payment < ActiveRecord::Base
#
# Journal type = 'Payment'
#
 
  belongs_to :event
  belongs_to :payer_account, class_name: "Account", foreign_key: :account_from
  belongs_to :payee_account, class_name: "Account", foreign_key: :account_to
  has_many :account_transactions, as: :journal
  has_many :allocations, as: :journal, dependent: :destroy
  has_many :accounts, through: :allocations

  accepts_nested_attributes_for :allocations, allow_destroy: true

  attr_accessor :payee_name, :payer_name

  scope :active, -> {where(deleted: false)}

  def payment_transaction
    self.account_transactions.where(entry_type: "payment" ).first
  end

  def receipt_transaction
    self.account_transactions.where(entry_type: "receipt" ).first
  end

  def payee_list(user)
    # Friends
    # Payee accounts
    User.all_friends(user).order(:user_name).map(&:user_name)
  end

  def user_to_user?
    self.payer_account.source_type != "User" || self.payee_account.source_type != "User"
  end

  def add_allocations
    puts "Running Payment.add_allocations"
    if self.user_to_user?
      self.allocations.new(account: self.payer_account, allocation_entry: 0.0)
      self.allocations.new(account: self.payee_account)
      self.for = Event::USER_TO_USER_PAYMENT
    else
      self.allocations.new(account: self.payer_account)
    end
  end


end

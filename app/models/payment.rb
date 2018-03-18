class Payment < ActiveRecord::Base
#
# Journal type = 'Payment'
# 
  validates :payment_date, presence: true
  validates :account_from, presence: true
  validates :account_to, presence: true

  belongs_to :event
  belongs_to :payer_account, class_name: "Account", foreign_key: :account_from
  belongs_to :payee_account, class_name: "Account", foreign_key: :account_to

  has_many :account_transactions, as: :journal
  has_many :account_transactions, as: :source, dependent: :destroy
  has_many :allocations, as: :journal, dependent: :destroy

  accepts_nested_attributes_for :allocations, allow_destroy: true

  attr_accessor :from_user_id, :to_user_id

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
    self.payer_account.source_type == "User" && self.payee_account.source_type == "User"
  end

  def to_event?
    self.payee_account.source_type == "Event"
  end

  def update_allocation_factors
    puts "Running allocation_process.update_allocation_factors for payment #{self.id}"
    amt_amount = self.allocations.where(allocation_method: "amt").sum(:allocation_entry)
    qty = self.allocations.where(allocation_method: "qty").sum(:allocation_entry)
    pct = self.allocations.where(allocation_method: "pct").sum(:allocation_entry)
    pct_amount = pct * (self.amount - amt_amount)
    qty_amount = self.amount - pct_amount - amt_amount
    self.allocations.each do |a|
      case a.allocation_method
        when "amt"
          a.allocation_factor = a.allocation_entry / self.amount
        when "pct"
          a.allocation_factor = a.allocation_entry
        when "qty"
          a.allocation_factor = (qty_amount / self.amount) * (a.allocation_entry / qty)
        else
          a.allocation_factor = 0
      end
      a.save
    end
  end

  def add_allocations
    if self.to_event?
      @event = self.event
      @event.user_accounts.each do |account|
        self.allocations.create(account: account, allocation_method: account.default_method, allocation_entry: account.default_share)
      end
    end
  end

  def delete_allocations
    self.allocations.destroy_all
  end

  def non_blank_payer_account
    if self.payer_account.blank?
      0
    else
      if self.payer_account.source_type == "User"
        self.payer_account.source_id
      else
        0
      end
    end
  end

  def non_blank_payee_account
    if self.payee_account.blank?
      0
    else
      if self.payee_account.source_type == "User"
        self.payee_account.source_id
      else
        0
      end
    end
  end

end

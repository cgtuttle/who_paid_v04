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
    # if self.payer_account && self.payee_account
      self.payer_account.source_type == "User" && self.payee_account.source_type == "User"
    # else
    #   false
    # end
  end

  def add_allocations
    if not self.user_to_user?
      self.allocations.new(account: self.payer_account)
    end
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

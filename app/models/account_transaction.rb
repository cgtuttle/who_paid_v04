class AccountTransaction < ActiveRecord::Base
  belongs_to :account
  has_many :accounts, as: :source
  has_many :entries, class_name: "AccountTransaction", foreign_key: "parent_entry_id"
  belongs_to :parent_entry, class_name: "AccountTransaction"

  def self.entries_of_type(entry_type)
    where(entry_type: entry_type).includes(:account)
  end

  def name
    self.account.account_name
  end

  def net_amount
    self.debit || 0 - self.credit || 0
  end

end

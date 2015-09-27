class Account < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :event

  has_many :account_transactions, dependent: :destroy
  has_many :payments_paid, class_name: "Payment", foreign_key: :account_from
  has_many :payments_received, class_name: "Payment", foreign_key: :account_to

  def self.list
    select(:account_name).uniq.order(:account_name).map(&:account_name)
  end

  def add_to_journal(journal_id, journal_type)
    transaction_set_id = AccountTransaction.where(
      journal_id: journal_id,
      journal_type: journal_type,
      entry_type: "distribution").pluck("transaction_set").first
      set_id = AccountTransaction.add_to_set(self.id,
      Time.now,
      "allocation",
      journal_id: journal_id,
      journal_type: journal_type,
      transaction_set:
      transaction_set_id)
  end

end

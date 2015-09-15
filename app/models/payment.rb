class Payment < ActiveRecord::Base
  belongs_to :event
  belongs_to :payer_account, class_name: "Account", foreign_key: :account_from
  belongs_to :payee_account, class_name: "Account", foreign_key: :account_to
  has_many :account_transactions, as: :journal

  def create_transactions
    from = Account.find(self.account_from)
    to = Account.find(self.account_to)
    set_id = AccountTransaction.add_to_set(from, self.payment_date, "payment", credit: self.amount, journal_id: self.id, journal_type: "Payment")
    AccountTransaction.add_to_set(to, self.payment_date, "receipt", debit: self.amount, transaction_set: set_id, journal_id: self.id, journal_type: "Payment")
    set_id = AccountTransaction.add_to_set(to, self.payment_date, "distribution", credit: self.amount, journal_id: self.id, journal_type: "Payment")
    AccountTransaction.add_to_set(from, self.payment_date, "allocation", debit: self.amount, transaction_set: set_id, journal_id: self.id, journal_type: "Payment")
  end


end

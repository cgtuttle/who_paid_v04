class PaymentProcess
	def initialize(payment)
		@payment = payment
		@date = @payment.payment_date
		@from = @payment.account_from
		@to = @payment.account_to
		@amount = @payment.amount
		@id = @payment.id
	end

# Main Payment Process
# ---------------
	def execute
		create_payment_transaction_set
		add_receipt_to_payment_set
		create_distribution_transaction_set
		add_allocation_to_distribution_set
		verify_journal_set
	end
# ---------------

  def create_payment_transaction_set
    @payment_set_id = AccountTransaction.add_to_set(@from, @date, "payment", credit: @amount, journal_id: @id, journal_type: "Payment")
  end

  def add_receipt_to_payment_set
    AccountTransaction.add_to_set(@to, @date, "receipt", debit: @amount, transaction_set: @payment_set_id, journal_id: @id, journal_type: "Payment")
  end

  def create_distribution_transaction_set
    @distribution_set_id = AccountTransaction.add_to_set(@to, @date, "distribution", credit: @amount, journal_id: @id, journal_type: "Payment")
  end

  def add_allocation_to_distribution_set
    AccountTransaction.add_to_set(@from, @date, "allocation", debit: @amount, transaction_set: @distribution_set_id, journal_id: @id, journal_type: "Payment")
  end

  def verify_journal_set
  end

end
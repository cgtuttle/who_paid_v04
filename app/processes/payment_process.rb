class PaymentProcess
# The goal here is to only create or reverse account transactions.
# CRUD operations on payments or allocations are out of the scope of this class.

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
    ActiveRecord::Base.transaction do
  		create_payment_transaction
  		create_receipt_transaction
    end  
  		create_allocation_transactions
  		verify_journal_set
	end
# ---------------

# Delete Payment Process
# ---------------
	def delete
    ActiveRecord::Base.transaction do
  		create_payment_transaction_reversal
  		create_receipt_transaction_reversal
    end
		reverse_allocation_transactions
		verify_journal_set
	end
# ---------------

# Update Payment Allocations Process
#----------------
  def update_allocations
    create_allocation_transactions
    verify_journal_set
  end
# ---------------

# ---------------
# Process tasks
# ---------------

  def create_payment_transaction
    @payment_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "payment"
    	t.journal_id = @id
    	t.journal_type = "Payment"
    	t.account_id = @from
    	t.credit = @amount
    end
  end

  def create_receipt_transaction
    @receipt_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type ="receipt"
    	t.journal_id = @id
    	t.journal_type = "Payment"
    	t.account_id = @to
    	t.debit = @amount
    end
  end

  def create_payment_transaction_reversal
    puts "Running create_payment_transaction_reversal for payment #{@payment.id}"
  	@payment_transaction = @payment.payment_transaction
  	@payment_reversal_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "reversal"
    	t.journal_id = @id
    	t.journal_type = "Payment"
    	t.account_id = @from
    	t.debit = @amount
  	end	
  	@payment_transaction.reversal_id = @payment_reversal_transaction.id
  	@payment_transaction.save
  end

  def create_receipt_transaction_reversal
  	@receipt_transaction = @payment.receipt_transaction
  	@receipt_reversal_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "reversal"
    	t.journal_id = @id
    	t.journal_type = "Payment"
    	t.account_id = @to
    	t.credit = @amount
      t.reversal_id = @receipt_transaction.id
  	end	
  	@receipt_transaction.reversal_id = @receipt_reversal_transaction.id
  	@receipt_transaction.save
  end

	def create_allocation_transactions
		@allocation_process = AllocationProcess.new(@payment).execute
	end

	def reverse_allocation_transactions
		@allocation_process = AllocationProcess.new(@payment).reverse
	end

  def verify_journal_set
  end

end
class PaymentProcess
# The goal here is to only create, or reverse or delete account transactions.
# CRUD operations on payments or allocations are out of the scope of this class.

	def initialize(payment)
    puts "Running payment_process.initialize"
		@payment = payment
		@date = @payment.payment_date
		@from = @payment.account_from
		@to = @payment.account_to
		@amount = @payment.amount
		@id = @payment.id
    @create_reversals = Rails.application.config_for(:process)["create_reversals"] # Choice to either create transaction reversals or delete them completely
	end

# ===============
# Processes
# ===============

# ---------------
# Create Payment Process
# ---------------
	def create
    puts "Running payment_process.create"
    ActiveRecord::Base.transaction do
  		create_payment_transaction
  		create_receipt_transaction
    end  
  		create_allocation_transactions
  		# verify_journal_set
	end

# ---------------
# Delete Payment Process
# ---------------
	def delete
    puts "Running payment_process.delete"
    if @create_reversals
      ActiveRecord::Base.transaction do
    		create_payment_transaction_reversal
    		create_receipt_transaction_reversal
      end
      create_allocation_transaction_reversals
    else
      delete_journal_transactions # payment, receipt, and allocation transactions
    end
		# verify_journal_set
	end

# ---------------
# Update Payment Allocations Process
#----------------
  def update_allocations
    puts "Running payment_process.update_allocations"
    create_allocation_transactions
    # verify_journal_set
  end


# ===============
# Process tasks
# ===============

# ---------------
# Creation
# ---------------
  def create_payment_transaction
    puts "Running payment_process.create_payment_transaction"
    @payment_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "payment"
    	t.journal_id = @id
    	t.journal_type = "Payment"
      t.source_id = @id
      t.source_type = "Payment"
    	t.account_id = @from
    	t.credit = @amount
    end
  end

  def create_receipt_transaction
    puts "Running payment_process.create_receipt_transaction"
    @receipt_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type ="receipt"
    	t.journal_id = @id
    	t.journal_type = "Payment"
      t.source_id = @id
      t.source_type = "Payment"
    	t.account_id = @to
    	t.debit = @amount
    end
  end

  def create_allocation_transactions
    puts "Running payment_process.create_allocation_transactions"
    @allocation_process = AllocationProcess.new(@payment).create
  end

# ---------------
# Reversal
# ---------------

  def create_payment_transaction_reversal
    puts "Running payment_process.create_payment_transaction_reversal for payment #{@payment.id}"
  	@payment_transaction = @payment.payment_transaction
  	@payment_reversal_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "reversal"
    	t.journal_id = @id
    	t.journal_type = "Payment"
      t.source_id = @id
      t.source_type = "Payment"
    	t.account_id = @from
    	t.debit = @amount
  	end	
  	@payment_transaction.reversal_id = @payment_reversal_transaction.id
  	@payment_transaction.save
  end

  def create_receipt_transaction_reversal
    puts "Running payment_process.create_receipt_transaction_reversal for payment #{@payment.id}"
  	@receipt_transaction = @payment.receipt_transaction
  	@receipt_reversal_transaction = AccountTransaction.create! do |t|
    	t.occurred_on = @date
    	t.entry_type = "reversal"
    	t.journal_id = @id
    	t.journal_type = "Payment"
      t.source_id = @id
      t.source_type = "Payment"
    	t.account_id = @to
    	t.credit = @amount
      t.reversal_id = @receipt_transaction.id
  	end	
  	@receipt_transaction.reversal_id = @receipt_reversal_transaction.id
  	@receipt_transaction.save
  end

  def create_allocation_transaction_reversals
    puts "Running payment_process.create_allocation_transaction_reversals for payment #{@payment.id}"
		@allocation_process = AllocationProcess.new(@payment).reverse
	end

# ---------------
# Destruction
# ---------------

  def delete_journal_transactions
    puts "Running delete_journal_transactions for payment #{@payment.id}"
    @payment.account_transactions.delete_all
  end

# ---------------
# Verification
# ---------------

  # def verify_journal_set
  #   puts "*** Verified payment_process ***"
  # end

end
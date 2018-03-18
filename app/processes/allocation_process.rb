class AllocationProcess
# The goal here is to only create, or reverse or delete account transactions.
# CRUD operations on payments or allocations are out of the scope of this class.

	def initialize(journal)
		puts "Running allocation_process.initialize"
		@journal = journal # This is a Payment or other source for the original line item that needs to be allocated
		@amount = @journal.amount
		@distribution_account = @journal.account_to # The "other side" of the set of transactions that will be created
		@allocations = @journal.allocations(true) # true to force reload
	end

# ===============
# Processes
# ===============

# ---------------
# Create Allocation Process
# ---------------
	def create
		puts "Running allocation_process.create"
		# update_allocation_factors
		create_allocation_transaction_reversals
		add_allocation_transactions
		verify_journal_set
	end

# ---------------
# Reverse Allocation Process
# ---------------
	def reverse
		puts "Running allocation_process.reverse"
		create_allocation_transaction_reversals
		verify_journal_set
	end

# ---------------
# Delete Allocation Process
# ---------------
	def delete
		puts "Running allocation_process.delete"
		delete_allocation_transactions
		verify_journal_set
	end

# ===============
# Process Tasks
# ===============

# ---------------
# Modification
# ---------------
	# def update_allocation_factors # This should not be in here! It modifies the allocation, not a transaction.
	# 	puts "Running allocation_process.update_allocation_factors for payment #{@journal.id}"
	# 	@amt_amount = @allocations.where(allocation_method: "amt").sum(:allocation_entry)
	# 	@qty = @journal.allocations.where(allocation_method: "qty").sum(:allocation_entry)
	# 	@pct = @journal.allocations.where(allocation_method: "pct").sum(:allocation_entry)
	# 	@pct_amount = @pct * (@amount - @amt_amount)
	# 	@qty_amount = @amount - @pct_amount - @amt_amount
	# 	@journal.allocations.each do |a|
	# 		case a.allocation_method
	# 			when "amt"
	# 				a.allocation_factor = a.allocation_entry / @amount
	# 			when "pct"
	# 				a.allocation_factor = a.allocation_entry
	# 			when "qty"
	# 				a.allocation_factor = (@qty_amount / @amount) * (a.allocation_entry / @qty)
	# 			else
	# 				a.allocation_factor = 0
	# 		end
	# 		a.save
	# 	end
	# end

# ---------------
# Creation
# ---------------
	def add_allocation_transactions
		puts "Running allocation_process.add_allocation_transactions for payment #{@journal.id}"
		@journal.allocations.each do |a|
			@journal.account_transactions.create do |t|	# Create distribution entries (the "other side" of the transaction)
				t.account_id = @distribution_account
				t.journal_id = a.id
				t.journal_type = "Allocation"
				t.credit = @amount * a.allocation_factor
				t.entry_type = "distribution"
				t.occurred_on = @journal.payment_date
			puts "Creating distribution transaction: #{t.inspect}"
			end
			@journal.account_transactions.create do |t| # Create allocation entries
				t.account_id = a.account_id
				t.journal_id = a.id
				t.journal_type = "Allocation"
				t.debit = @amount * a.allocation_factor
				t.entry_type = "allocation"
				t.occurred_on = @journal.payment_date
			puts "Creating allocation transaction: #{t.inspect}"
			end
		end
	end

# ---------------
# Reversal
# ---------------
	def create_allocation_transaction_reversals
		# Only reverse allocation entries that haven't been reversed already and don't reverse reversals
		puts "Running allocation_process.create_allocation_transaction_reversals for payment #{@journal.id}"
		@journal.account_transactions.where(journal_type: "Allocation", reversal_id: nil ).where.not(entry_type: "reversal").each do |a|
			"Creating reversal transaction: #{a.inspect}"
			@reversal = @journal.account_transactions.create do |t|
				t.account_id = a.account_id
				t.journal_id = a.journal_id
				t.journal_type = a.journal_type
				t.debit = a.credit
				t.credit = a.debit
				t.entry_type = "reversal"
				t.reversal_id = a.id
				t.occurred_on = @journal.payment_date
			end
			a.reversal_id = @reversal.id
			a.save
		end
	end

# ---------------
# Destruction
# ---------------
	def delete_allocation_transactions
		puts "Running allocation_process.delete_allocation_transactions for payment #{@journal.id}"
		@journal.account_transactions.where(journal_type: "Allocation").delete_all
	end

# ---------------
# Verification
# ---------------
	def verify_journal_set
		puts "*** Verified allocation_process ***"
	end

end


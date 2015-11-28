class AllocationProcess
	def initialize(journal)
		@journal = journal
		@amount = @journal.amount
		@distribution_account = @journal.account_to
		@allocations = @journal.allocations(true)
	end

# Main Allocation Process
# ---------------
	def execute
		update_allocation_factors
		reverse_allocation_transactions
		add_allocation_transactions
		verify_journal_set
	end
# ---------------

# Destroy Allocation Process
# ---------------
	def reverse
		reverse_allocation_transactions
		verify_journal_set
	end
# ---------------

	def update_allocation_factors
		@amt_amount = @allocations.where(allocation_method: "amt").sum(:allocation_entry)
		@qty = @journal.allocations.where(allocation_method: "qty").sum(:allocation_entry)
		@pct = @journal.allocations.where(allocation_method: "pct").sum(:allocation_entry)
		@pct_amount = @pct * (@amount - @amt_amount)
		@qty_amount = @amount - @pct_amount - @amt_amount
		@journal.allocations.each do |a|
			case a.allocation_method
				when "amt"
					a.allocation_factor = a.allocation_entry / @amount
				when "pct"
					a.allocation_factor = a.allocation_entry
				when "qty"
					a.allocation_factor = (@qty_amount / @amount) * (a.allocation_entry / @qty)
				else
					a.allocation_factor = 0
			end
			a.save
		end
	end

	def reverse_allocation_transactions
		# Only reverse allocation entries that haven't been reversed already and don't reverse reversals
		@journal.account_transactions.where(sub_journal_type: "Allocation", reversal_id: nil ).where.not(entry_type: "reversal").each do |a|
			@reversal = @journal.account_transactions.create do |t|
				t.account_id = a.account_id
				t.sub_journal_id = a.sub_journal_id
				t.sub_journal_type = a.sub_journal_type
				t.debit = a.credit
				t.credit = a.debit
				t.entry_type = "reversal"
				t.reversal_id = a.id
			end
			a.reversal_id = @reversal.id
			a.save
		end
	end

	def add_allocation_transactions
		@journal.allocations.each do |a|
			@journal.account_transactions.create do |t|	# Create distribution entries	
				t.account_id = @distribution_account
				t.sub_journal_id = a.id
				t.sub_journal_type = "Allocation"
				t.credit = @amount * a.allocation_factor
				t.entry_type = "distribution"
			end
			@journal.account_transactions.create do |t| # Create allocation entries
				t.account_id = a.account_id
				t.sub_journal_id = a.id
				t.sub_journal_type = "Allocation"
				t.debit = @amount * a.allocation_factor
				t.entry_type = "allocation"
			end
		end
	end

	def verify_journal_set
	end

end


class account_transaction_process
	def initialize(journal)
		@journal = journal
	end

	def remove_allocation_reversals
		@journal.account_transactions.where("sub_journal_type = (?), reversal_id > (?)", "Allocation", 0 ).delete_all
	end

end
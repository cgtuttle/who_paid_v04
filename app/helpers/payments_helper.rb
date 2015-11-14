module PaymentsHelper

	def accounts_list(current_event)
		current_event.accounts.map(&:account_name).uniq.compact!.sort
	end

end

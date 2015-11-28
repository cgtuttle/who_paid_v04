module PaymentsHelper

	def accounts_list(current_event)
		current_event.accounts.map(&:account_name).uniq.compact.sort
	end

	def setup_payment(event, payment)
		(event.accounts.user - payment.accounts).each do |account|
			payment.allocations.build(account: account)
		end
		payment
	end

end

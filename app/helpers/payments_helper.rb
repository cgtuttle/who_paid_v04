module PaymentsHelper

	def payment_allocation_choices(event, payment)
		(event.user_accounts).each do |account|
			if account.allocations.where(journal_type: "Payment", journal_id: payment.id).empty?
				payment.allocations.new(account: account)
			end
		end
		payment
	end

end

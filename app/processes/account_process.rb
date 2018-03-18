class AccountProcess
	def initialize(account)
		@account = account
		@create_reversals = Rails.application.config_for(:process)["create_reversals"]
		@delete_payments = Rails.application.config_for(:process)["delete_payments"]
	end

	def delete
		if @create_reversals
		else
			@account.payments.each do |p|
				PaymentProcess.new(p).delete
				p.allocations.where(account: @account).delete_all
				PaymentProcess.new(p).create
			end
		end
		if @delete_payments
			@account.destroy
		else
			@account.inactive = true
			@account.save
		end
	end
end
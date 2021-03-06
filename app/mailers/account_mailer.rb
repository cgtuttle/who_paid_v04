class AccountMailer < ApplicationMailer
	add_template_helper(ApplicationHelper)
	default from: 'accounts@whopaid.us'

	def statement_email(user, account, transactions)
		@user = user
		@account = account
		@event = @account.event
		@transactions = transactions
		mail to: @user.email, subject: "#{@event.name} Statement for #{@user.first_name} #{@user.last_name}"
	end

end
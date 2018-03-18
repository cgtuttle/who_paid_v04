class StatementMailer < ApplicationMailer

	def statement_message(user, from, subject, content, sender)
		@user = user
		@message = content
		mail(:to => @user.email, :subject => subject) do |format|
			format.html do
				render 'events/mailers/statement/message'
			end
		end
	end

end
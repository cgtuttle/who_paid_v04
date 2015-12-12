class InvitationMailer < ActionMailer::Base
	# default from: 'noreply@whopaid.us'

	def invite_message(user, from, subject, content, sender)
		@user = user
		user.invite! do |u| # This is necessary to generate a user token. It will not generate a new user record.
			u.skip_invitation = true
		end
		@token = user.raw_invitation_token
		puts "raw_invitation_token = #{user.raw_invitation_token}"
		invitation_link = accept_user_invitation_url(:invitation_token => @token)
		@message = content
		mail(:from => from, :bcc => from, :to => @user.email, :subject => subject) do |format|
			format.html do
				render 'devise/mailer/invitation_instructions'
			end
		end
	end

end
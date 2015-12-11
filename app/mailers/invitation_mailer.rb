class InvitationMailer < ActionMailer::Base
	default from: 'noreply@whopaid.us'

	def invite_message(user, from, subject, content, sender)
		puts "Running InvitationMailer.invite_message"
		@user = user
		@token = '1000000000'#user.raw_invitation_token
		invitation_link = accept_user_invitation_url(:invitation_token => @token)
		puts "@user = #{@user} from InvitationMailer.invite_message"
		@message = content
		mail(:from => from, :bcc => from, :to => @user.email, :subject => subject) do |format|
			format.html do
				render 'devise/mailer/invitation_instructions'
			end
		end
	end

end
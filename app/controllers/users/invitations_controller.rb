class Users::InvitationsController < Devise::InvitationsController

# Workflow
# --------
# create >> devise/mailer/invitation_message >> render 'devise/mailer/form' >> submit (Send) >> deliver >>
# mailers/invitation_mailer.invite_message >> mail >> devise/mailer/invitation_instructions

# Key mailer statement
# --------------------
# mail(:to => @user.email, :subject => subject) do |format|
# 	format.html do
# 		render 'devise/mailer/invitation_instructions'
# 	end
# end

	before_filter :configure_permitted_parameters, if: :devise_controller?

	def create
		@user = User.find(params[:id])
		@token = @user.raw_invitation_token
		render 'devise/mailer/invitation_message'
	end

	def deliver
		user = User.find(params[:id])
		@content = params[:message]
		@subject = "Invitation to WhoPaid from #{current_user.display_name}"
		@from = "no-reply@test.com"
		InvitationMailer.invite_message(user, @from, @subject, @content, current_user).deliver_now if user.errors.empty? 
		if user.errors.empty?			
			redirect_to users_path, notice: "Sent invitation to #{user.display_name}"
			user.invitation_sent_at = Time.now.utc
			user.save(validate: false)
		else
			render 'new'
		end
	end

	private

	def resource_params
		params.permit(user: [:first_name, :last_name, :user_name, :email, :invitation_token])[:user]
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:invite) { |u| u.permit(:first_name, :last_name, :user_name, :email, :password, :password_confirmation) }
	end

end

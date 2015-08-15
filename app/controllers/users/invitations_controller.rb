class Users::InvitationsController < Devise::InvitationsController
	before_filter :configure_permitted_parameters, if: :devise_controller?

	def create
		@user = User.find(params[:id])
		render 'devise/mailer/invitation_message'
	end

	def deliver
		user = User.find(params[:id])
		@content = params[:message]
		@subject = "Invitation to WhoPaid from #{current_user.display_name}"
		@from = "no-reply@test.com"
		InvitationMailer.invite_message(user, @from, @subject, @content).deliver if user.errors.empty?
		user.invitation_sent_at = Time.now.utc # mark invitation as delivered
		# user.invite!(current_user)
		redirect_to users_path, notice: "Sent invitation to #{user.display_name}"
	end

	private

	def resource_params
		params.permit(user: [:first_name, :last_name, :user_name, :email, :invitation_token])[:user]
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:invite) { |u| u.permit(:first_name, :last_name, :user_name, :email, :password, :password_confirmation) }
	end

end
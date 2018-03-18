class UserProcess

	def initialize(params)
    @routes = Rails.application.routes.url_helpers
    @redirect_path = @routes.users_path    
		@params = params
    @user = User.new
	end

	def setup   
    @email = @params[:user][:email].downcase
    if User.exists?(["lower(email) = (?)", @email]) || @email == ""
      @user = User.where('lower(email) = (?)', @email).first
    else
      @user = User.new
      @user.email = @email
      @user.first_name = @params[:user][:first_name]
      @user.last_name = @params[:user][:last_name]
      @user.created_by_id = @params[:current_user_id]
      @user.role = "guest"
      @user.save!
      @user
    end
  end

  def user
    @user
  end

  def redirect_path
    @redirect_path
  end

end
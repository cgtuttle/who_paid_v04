class UserSetupProcess


	def initialize(params)
    @routes = Rails.application.routes.url_helpers
    @redirect_path = @routes.users_path    
		@params = params
    @user = User.new
	end

	def setup     
    @email = @params[:user][:email].downcase
    if User.exists?(["lower(email) = (?)", @email]) || @email == ""
      puts "Path: User Exists"
      @user = User.where('lower(email) = (?)', @email).first
    else
      puts "Path: User Does Not Exist - Create New"
      @user.email = @email
      @user.first_name = @params[:user][:first_name]
      @user.last_name = @params[:user][:last_name]
      @user.created_by_id = @params[:current_user_id]
      @user.role = "guest"
      @user.save!
    end
    if @params[:account]
      Account.find_or_create_by(id: @params[:account][:id]) do |account|
        account.source_id = @user.id
        account.source_type = "User"
      end
    end   
    if @params[:user][:is_account_user] == "true"
      puts "Is Account User? #{@params[:user][:is_account_user]}"
      @account = Account.create(source_id: @user.id, source_type: "User", account_name: @user.display_name, event_id: @params[:user][:event_id] )
      @redirect_path = @routes.event_path(@params[:user][:event_id])
    end
    @redirect_path
  end

end
class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_resources, :only => [:edit, :show, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :scope_policy, :only => :index


  def create
    params[:current_user_id] = current_user.id
    @user = UserProcess.new(params)
    @user.setup
    @user.create_account(current_event) if session[:new_user_type] == "account_user"
    redirect_to @user.redirect_path, notice: "New user successfully created."
  end

  def destroy
    if @user.destroy
      @user.update_accounts
      redirect_to users_path, :notice => "User deleted."
    end
  end

  def edit
    @cancel_path = users_path
  end

  def new
    uri = URI.encode(request.referer)
    if URI.split(uri)[5].include? "user"
      session[:new_user_type] = "user"
    else
      session[:new_user_type] = "account_user"
    end
    logger.debug "New user type = #{session[:new_user_type]}"
    @user = User.new
    @cancel_path = request.referer
  end

  def new_guest
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
  end

  def update
    if @user.update_attributes(user_params)
      logger.debug "User updated: #{@user.display_name}"
      @user.update_accounts
      redirect_to users_path, :notice => "User and Account details updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  private

    def set_resources
      if params[:id]
        logger.debug "params[:id] = #{params[:id]}"
        @user = User.find(params[:id])
      end
      logger.info "User = #{@user.inspect}"
      logger.info "Current User = #{current_user}"
      logger.info "Current event = #{@current_event.inspect}"
    end

    def user_params
      params.require(:user).permit(:role, :first_name, :last_name, :email)
    end

    def account_params
      params.require(:account)
    end

    def authorize_action
      authorize @user
    end

    def scope_policy
      @users = policy_scope(User).order(:email)
      logger.info "Policy scoping User"
    end

end

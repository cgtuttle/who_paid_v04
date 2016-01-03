class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_resources, :only => [:edit, :show, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :scope_policy, :only => :index


  def create
    @user = User.new    
    @email = params[:user][:email].downcase
    logger.debug "@email = #{@email}"
    if !User.exists?(["lower(email) = (?)", @email])
      @user.email = params[:user][:email]
      @user.first_name = params[:user][:first_name]
      @user.last_name = params[:user][:last_name]
      @user.save!
    else
      @user = User.where('lower(email) = (?)', @email).first
      logger.debug "User #{@user.display_name} exists"
    end
    if params[:account]
      @account = Account.find(params[:account][:id])
      @account.source_id = @user.id
      @account.source_type = "User"
      @account.save!
    end
    redirect_to users_path, notice: "New user successfully created."
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
    @user = User.new
    @cancel_path = users_path
    if params[:account]
      @account = Account.find(params[:id])
      @user.parse_display_name(@account.account_name)
      @cancel_path = event_path(current_event.id)
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

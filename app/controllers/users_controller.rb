class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_resources, :only => [:edit, :show, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :scope_policy, :only => :index


  def create
    @user = User.new
    @account = Account.find(params[:account][:id])
    @email = params[:user][:email].downcase
    logger.debug "@email = #{@email}"
    if !User.exists?(["lower(email) = (?)", @email])
      @user.email = params[:user][:email]
      @user.first_name = params[:user][:first_name]
      @user.last_name = params[:user][:last_name]
      if !@user.save
        render 'users/new_from_account' and return
      end
    else
      @user = User.where('lower(email) = (?)', @email).first
      logger.debug "User #{@user.display_name} exists"
    end
    @account.source_id = @user.id
    @account.source_type = "User"
    @account.save
    redirect_to event_path(current_event)
  end

  def edit
    @cancel_path = users_path
  end

  def new
    @user = User.new
    @cancel_path = users_path
  end

  def new_from_account
    @account = Account.find(params[:id])
    @user = User.new
    @user.parse_display_name(@account.account_name)
    @cancel_path = event_path(current_event.id)
  end

  def show
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, :notice => "User deleted."
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

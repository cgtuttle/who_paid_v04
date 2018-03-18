class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_resources, :only => [:edit, :show, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :scope_policy, :only => :index

# The purpose of this controller is for admins to manage users directly, independently
# of the usual Devise signup/update process, which is why it does not extend Devise::WhateverController.
# To allow this to work, password_required? is overridden to false in the user model. This only affects 
# validations - passwords are always required for new records.

  def create
    params[:current_user_id] = current_user.id
    @user_process = UserProcess.new(params)
    @user = @user_process.setup
    @user.create_account(name: @user.display_name)
    redirect_to @user_process.redirect_path, notice: "New user successfully created."
  end

  def destroy
    if @user.destroy
      @user.update_account
      redirect_to users_path, :notice => "User deleted."
    end
  end

  def edit
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
    @account = @user.account
    @transactions = @account.statement_transactions
    @payments = @account.payments
  end

  def update
    @user.update_account
    if @user.update(user_params)
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
      logger.info "Current event = #{current_event.inspect}"
    end

    def user_params
      params[:user].permit(:role, :first_name, :last_name, :email)
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

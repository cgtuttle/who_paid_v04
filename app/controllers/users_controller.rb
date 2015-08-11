class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_resources, :only => [:edit, :show, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :scope_policy, :only => :index

  def edit
  end

  def show
  end

  def update
    if @user.update_attributes(secure_params)
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

    def secure_params
      params.require(:user).permit(:role, :name, :email)
    end

    def authorize_action
      authorize @user
    end

    def scope_policy
      @users = policy_scope(User).order(:email)
      logger.info "Policy scoping User"
    end

end

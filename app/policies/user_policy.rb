class UserPolicy < ApplicationPolicy

  def initialize(user, model)
    @current_user = user
    @user = model
  end

  def show?
    true
  end

  def edit?
    @current_user.admin? || @current_user == @user
  end

  def update?
    @current_user.admin? || @current_user == @user
  end

  def destroy?
    return false if @current_user == @user
    @current_user.admin?
  end

  def admin?
    @current_user.admin?
  end

  def change_role?
    @current_user.admin?
  end

  class Scope < Scope
    def resolve # all users with at least one event in common with current_user, unless admin then all
      puts "user = #{user}"
      if user.admin?
        User.all
      else
        user.all_friends.uniq
      end
    end
  end

end

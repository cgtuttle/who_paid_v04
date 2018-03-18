class EventPolicy < ApplicationPolicy

	class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
    		# scope.joins(:accounts).where("account.source_id = ? AND account.source_type = ?", user.id, "User").order(:name)
        scope.joins(:users).where("user_id = ?", user.id)
    	end
    end
  end
	
  def show?
    user.admin? || @record.member?(user)
  end

  def create?
  	true
  end

  def destroy?
  	user.admin? || @record.owner?(user)
  end

  def edit?
    user.admin? || @record.owner?(user)
  end

  def new?
  	true
  end

  def update?
  	user.admin? || @record.owner?(user)
  end

end

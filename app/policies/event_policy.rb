class EventPolicy < ApplicationPolicy

	class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
    		scope.joins(:accounts).where("accounts.source_id = ? AND accounts.source_type = ?", user.id, "User")
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

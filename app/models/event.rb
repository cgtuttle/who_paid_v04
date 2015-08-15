class Event < ActiveRecord::Base
  has_many :accounts
  has_many :account_transactions, through: :accounts
  has_many :users, through: :accounts, source: :source, source_type: "User", dependent: :destroy
  belongs_to :owner, class_name: "User"

  def owner?(user)
		self.owner_id == (user.id)
	end

	def member?(user)
		self.users.exists?(user)
	end

  def create_event_owner_account(user)
    self.accounts.create!(source: user, name: user.display_name)
  end
  
  def parent_entries
    self.account_transactions.where(parent_entry_id: 0)
  end

  def entries_of_type(entry_type)
    self.account_transactions.entries_of_type(entry_type)
  end

  def total_amount(entry_type)
    self.entries_of_type(entry_type).sum(:credit) - self.entries_of_type(entry_type).sum(:debit)
  end

  def source_names(entry_type)
    self.entries_of_type(entry_type).source.account_name
  end

end

class Event < ActiveRecord::Base
  has_many :accounts
  has_many :payments
  has_many :account_transactions, through: :accounts
  has_many :users, through: :accounts, source: :source, source_type: "User", dependent: :destroy
  has_many :payees, through: :accounts, source: :source, source_type: "Payee", dependent: :destroy
  belongs_to :owner, class_name: "User"

  def owner?(user)
		self.owner_id == (user.id)
	end

	def member?(user)
		self.users.exists?(user.id)
	end

  def create_event_owner_account(user)
    self.accounts.create!(source: user, account_name: user.display_name)
  end

  def create_event_default_account
    self.accounts.create!(account_name: self.name)
  end

  def entries_of_type(entry_type)
    self.account_transactions.entries_of_type(entry_type)
  end

  def total_amount(entry_type)
    self.entries_of_type(entry_type).sum(:credit) - self.entries_of_type(entry_type).sum(:debit)
  end

end

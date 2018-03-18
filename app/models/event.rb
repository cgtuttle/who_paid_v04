class Event < ActiveRecord::Base
  has_one :account, as: :source, dependent: :destroy
  has_many :payments_paid, through: :account
  has_many :payments_received, through: :account
  has_many :payments
  has_many :allocations, through: :account
  has_many :account_transactions, through: :payments
  has_many :memberships
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"
  validates :name, uniqueness: { scope: :owner_id, message: "already exists"}

  USER_TO_USER_PAYMENT = "Settlement"

  def user_accounts
    Account.includes(:source).where("source_type = ? AND source_id IN (?)", "User", self.users.select(:id))
  end

  def owner?(user)
		self.owner_id == (user.id)
	end

	def member?(user)
		self.users.exists?(user.id)
	end

  def entries_of_type(entry_type)
    self.account_transactions.entries_of_type(entry_type)
  end

  def total_expenses
    self.account_transactions.entries_of_type("receipt").sum(:debit)
  end

  def user_balance(user)
    logger.debug "Running user_balance for #{user}"
    logger.debug "user.account.id = #{user.account.id}"
    self.account_transactions.where(account_id: user.account.id).sum(:credit) - self.account_transactions.where(account_id: user.account.id).sum(:debit)
  end

  def display_name
    self.name
  end

  # def account_group
  #   self.all
  # end
  
  # def event_account
  #   self.account
  # end

  # def owner_account
  #   Account.includes(:source).where(source_type: "User", source_id: self.owner_id)
  # end

  # def total_amount(entry_type)
  #   self.entries_of_type(entry_type).sum(:credit) - self.entries_of_type(entry_type).sum(:debit)
  # end

end

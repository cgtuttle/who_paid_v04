class User < ActiveRecord::Base

  validates :email, presence: true, uniqueness: true, if: :email_required?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_reader :raw_invitation_token
  attr_accessor :current_password

  has_one :account, as: :source, dependent: :destroy
  has_many :owned_events, class_name: "Event", foreign_key: "owner_id"
  has_many :memberships
  has_many :events, through: :memberships
  has_many :account_transactions, through: :account
  has_many :payments_paid, through: :account
  has_many :payments_received, through: :account
  has_many :allocations, through: :account

  enum role: [:guest, :user, :editor, :admin]
  after_initialize :set_default_role, :if => :new_record?

  scope :invited_by_user, ->(user) {where(invited_by_id: user)}
  scope :created_by_user, ->(user) {where(created_by_id: user)}

  def self.new_guest(event)
    new { |u| u.role = "guest"}
  end

  def password_required?    
    false
  end

  def email_required?
    self.role != "guest"
  end

  def set_default_role
    self.role ||= :user
  end

  def update_account
    if self.account.blank?
      self.create_account(name: self.display_name)
    else
      self.account.name = self.display_name
      self.account.save!
    end
  end

  def account_group # ????
    self.all
  end

  def event_accounts
    Account.includes(:source).where("source_type = ? AND source_id IN (?)", "Event", self.events.select(:id))
  end


  def event_friends
    User.joins(memberships: :event).where("event_id IN (?)", self.events.select('id')).distinct
  end

  def self.all_friends(user)
    if user.role == 'admin'
      User.all
    else
      query1 = user.event_friends
      query2 = User.where('id = ?', user.id)
      query3 = User.invited_by_user(user)
      sql = User.connection.unprepared_statement{"((#{query1.to_sql}) UNION (#{query2.to_sql}) UNION (#{query3.to_sql})) as users"}
      User.from(sql)
    end
  end

  def all_friends
    if self.role == 'admin'
      users = User.all.order(:last_name, :first_name)
    else
      query1 = self.event_friends
      query2 = User.where('id = ?', self.id)
      query3 = User.created_by_user(self)
      sql = User.connection.unprepared_statement{"((#{query1.to_sql}) UNION (#{query2.to_sql}) UNION (#{query3.to_sql})) as users"}
      users = User.from(sql).order(:last_name, :first_name)
    end
  end

  def friends(event)
    all_friends = self.all_friends - event.users
    all_friends = all_friends.map{|x| [x.id, x.display_name]}
  end

  def display_name
    if !self.first_name.blank? && !self.last_name.blank?
      "#{self.first_name} #{self.last_name}".titleize
    elsif !self.user_name.blank?
      self.user_name
    else
      self.email
    end
  end

  def parse_display_name(display_name)
    self.first_name = display_name.split[0]
    self.last_name = display_name.split[1]
    display_name
  end

# Deprecated
# ******************************
  # def update_accounts
  #   self.accounts.each do |account|
  #     if self.destroyed?
  #       account.source_id = nil
  #     end
  #     account.name = self.display_name
  #     account.save!
  #   end
  # end
# ******************************

# Deprecated
# ******************************
  # def event_balance(event)
  #   balance = 0
  #   self.accounts.each do |account|
  #     if account.event == event
  #       balance = account.balance
  #     end
  #   end
  #   return balance
  # end
# ******************************

# Deprecated
# ******************************
  # def friend_accounts(event)
  #   Account.where("event_id IN (?) AND source_type = 'User' AND source_id is null", self.events.select('id')) - Account.where(event_id: event.id)
  # end
# ******************************

end

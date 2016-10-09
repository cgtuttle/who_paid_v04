class User < ActiveRecord::Base

  validates :email, presence: true, uniqueness: true, if: :email_required?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_reader :raw_invitation_token
  attr_accessor :current_password

  has_many :accounts, as: :source
  has_many :events, through: :accounts
  has_many :owned_events, class_name: "Event", foreign_key: "owner_id"

  enum role: [:guest, :user, :editor, :admin]
  after_initialize :set_default_role, :if => :new_record?

  scope :invited_by_user, ->(user) {where(invited_by_id: user)}
  scope :created_by_user, ->(user) {where(created_by_id: user)}

  def self.new_guest(event)
    new { |u| u.role = "guest"}
  end

  def password_required?    
    self.role != "guest"
  end

  def email_required?
    self.role != "guest"
  end

  def set_default_role
    self.role ||= :user
  end

  def update_accounts
    self.accounts.each do |account|
      if self.destroyed?
        account.source_id = nil
      end
      account.account_name = self.display_name
      account.save!
    end
  end

  def friend_accounts(event)
    Account.where("event_id IN (?) AND source_type = 'User' AND source_id is null", self.events.select('id')) - Account.where(event_id: event.id)
  end

  def event_friends
    User.joins(accounts: :event).where("event_id IN (?)", self.events.select('id')).distinct
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

  def account_group
    self.all
  end

  def friends(event)
    all_friends = self.all_friends - event.users
    all_friends = all_friends.map{|x| [x.id, x.display_name]}
    friend_accounts = self.friend_accounts(event).map{|x| [""] + [x.account_name]}.flatten(1)
    all_friends.push(friend_accounts)
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

end

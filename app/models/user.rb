class User < ActiveRecord::Base

  validates :email, presence: true, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_reader :raw_invitation_token

  has_many :accounts, as: :source
  has_many :events, through: :accounts
  has_many :owned_events, class_name: "Event", foreign_key: "owner_id"

  enum role: [:user, :editor, :admin]
  after_initialize :set_default_role, :if => :new_record?

  scope :invited_by_user, ->(user) {where(invited_by_id: user)}

  def password_required?
    new_record? ? false : true
  end

  def set_default_role
    self.role ||= :user
  end

  def event_friends
    User.joins(accounts: :event).where("event_id IN (?)", self.events.select('id'))
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
      User.all
    else
      query1 = self.event_friends
      query2 = User.where('id = ?', self.id)
      query3 = User.invited_by_user(self)
      sql = User.connection.unprepared_statement{"((#{query1.to_sql}) UNION (#{query2.to_sql}) UNION (#{query3.to_sql})) as users"}
      User.from(sql)
    end
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

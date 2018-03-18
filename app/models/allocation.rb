class Allocation < ActiveRecord::Base

  before_save :set_defaults

  belongs_to :account

  belongs_to :journal, polymorphic: true
  has_many :account_transactions, as: :journal
  has_many :account_transactions, as: :source, dependent: :destroy

  ALLOCATION_METHODS = ['qty','amt','pct']

  scope :amt_allocation, -> {where(allocation_method: "amt")}
  scope :pct_allocation, -> {where(allocation_method: "pct")}
  scope :qty_allocation, -> {where(allocation_method: "qty")}

  scope :by_last_name, -> { joins("join accounts on account.id = account_id 
                                  join users on users.id = account.source_id")
                            .where("account.source_type = 'User'")
                            .order("users.last_name") }

private
  
  def set_defaults
    self.allocation_method ||= 'qty'
    self.allocation_entry ||= 1.0
  end

end

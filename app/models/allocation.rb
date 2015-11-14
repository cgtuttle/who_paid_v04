class Allocation < ActiveRecord::Base

  belongs_to :journal, polymorphic: true
  belongs_to :account
  has_many :account_transactions, as: :sub_journal

  scope :amt_allocation, -> {where(allocation_method: "amt")}
  scope :pct_allocation, -> {where(allocation_method: "pct")}
  scope :qty_allocation, -> {where(allocation_method: "qty")}

end

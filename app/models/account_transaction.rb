class AccountTransaction < ActiveRecord::Base
  belongs_to :journal, polymorphic: true
  belongs_to :sub_journal, polymorphic: true
  belongs_to :account

  scope :not_reversed, -> {where('reversal_id is ? and entry_type != (?)', nil, "reversal" )}
 
  def self.journal_allocation_set?(journal_id, journal_type)
    @journal_set = journal_set(journal_id, journal_type)
    #
    # To properly allocate, journal set must have
    # at least one payment and one allocation
    #
    payment_count = @journal_set.where(entry_type: "payment").count
    allocation_count = @journal_set.where(entry_type: "allocation").count
    return ((payment_count > 0) and (allocation_count > 0))
  end

  def self.transaction_set(set_id)
    where(transaction_set: set_id)
  end

  def self.allocation_set
    where(entry_type: "allocation")
  end

  def self.journal_set(journal_id, journal_type)
    @journal_set = where(journal_id: journal_id, journal_type: journal_type)
  end

  def self.entries_of_type(entry_type)
    not_reversed.where(entry_type: entry_type).includes(:account)
  end

  def name
    self.account.account_name
  end

  def net_amount
    self.debit || 0 - self.credit || 0
  end

  def allocation_factor
    if self.entry_type == "allocation"
      allocation = Allocation.find(self.sub_journal_id)
      allocation.allocation_factor
    else
      1
    end
  end

end

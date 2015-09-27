class AccountTransaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :journal, polymorphic: true

  # add_to_set
  #
  # Create one entry in a transaction set of debits and credits with either the entry
  # as its own set_id (typically the first entry in the set) or by passing the set_id as an
  # optional parameter (transaction_set)
  #
  # options:
  #   :credit - credit amount (decimal)
  #   :debit - debit amount (decimal)
  #   :journal_id - source journal entry id
  #   :journal_type - journal class name
  #   :transaction_set - identifier to group a set of balancing cr/dr transactions
  #     defaults to this transaction
  #
  def self.add_to_set(account_id, transaction_date, type, options={})
    entry = self.new
    entry.account_id = account_id
    entry.occured_on = transaction_date
    entry.credit = options[:credit]
    entry.debit = options[:debit]
    entry.entry_type = type
    entry.journal_id = options[:journal_id]
    entry.journal_type = options[:journal_type]
    entry.save
    entry.transaction_set = options[:transaction_set] || entry.id
    entry.save
    entry.id
  end

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

  #============================================
  # This should actually be handled by
  # allocation tables if there are more
  # than a few ways of allocating

  def self.reallocate(journal_id, journal_type)
    @journal_set = journal_set(journal_id, journal_type)
    payment_set = @journal_set.where(entry_type: "payment")
    @sum_payment = payment_set.sum("credit") - payment_set.sum("debit")
    amt_factors(journal_id, journal_type)
    pct_factors(journal_id, journal_type)
    total_factors
    qty_factors(journal_id, journal_type)
    allocation_set = @journal_set.where(entry_type: "allocation")
    allocation_set.each do |entry|
      if @sum_payment > 0
        case entry.allocation_method
        when "amt"
          entry.allocation_factor = entry.allocation_entry / @sum_payment
        when "pct"
          entry.allocation_factor = entry.allocation_entry
        when "qty"
          entry.allocation_factor = @indirect_factor * entry.allocation_entry / @count_qty
        end
      else
        entry.allocation_factor = 0
      end
      entry.debit = @sum_payment * entry.allocation_factor
      entry.save
    end
  end

  def self.amt_factors(journal_id, journal_type)
    @amt_set = @journal_set.where(allocation_method: "amt")
    @sum_amt = @amt_set.empty? ? 0.0 : @amt_set.sum("allocation_entry").to_f
    @count_amt = @amt_set.count
    @amt_factor = @sum_amt / @sum_payment.to_f
  end

  def self.pct_factors(journal_id, journal_type)
    @pct_set = @journal_set.where(allocation_method: "pct")
    @sum_pct = @pct_set.sum("allocation_entry").to_f
    @count_pct = @pct_set.count
    @pct_factor = @sum_pct
  end

  def self.qty_factors(journal_id, journal_type)
    @qty_set = @journal_set.where(allocation_method: "qty")
    @sum_qty = @qty_set.sum("allocation_entry")
    @count_qty = @sum_qty
  end

  def self.total_factors
    @direct_factor = @amt_factor + @pct_factor
    @indirect_factor = 1 - @direct_factor
  end

  #============================================

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
    where(entry_type: entry_type).includes(:account)
  end

  def name
    self.account.account_name
  end

  def net_amount
    self.debit || 0 - self.credit || 0
  end

end

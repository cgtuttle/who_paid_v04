require 'test_helper'

class AccountTransactionTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test 'added to set?' do
    assert_difference('AccountTransaction.count') do
      AccountTransaction.add_to_set(@account, Time.now, 'payment', journal_id: 1, journal_type:  'Payment')
    end
  end

  test 'reallocated?' do
    AccountTransaction.reallocate(1, "Payment")
    expected = 50
    actual = AccountTransaction.where(journal_id: 1, journal_type: "Payment").sum("credit")
    assert_equal(expected, actual)
  end

  test 'journal allocation can be tested?' do
    assert AccountTransaction.journal_allocation_set?(1, "Payment")
  end

end

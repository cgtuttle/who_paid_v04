require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @event = events(:one)
  end

  test 'owner?' do
    assert(@event.owner?(@user))
  end

  test 'member?' do
    assert @event.member?(@user), "event.users = #{@event.users.first}"
  end

  test 'total_amount' do
    assert_equal @event.total_amount('payment'), -50.00
  end

end

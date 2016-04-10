require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @user = users(:user_one)
    @event = events(:one)
  end

  test 'owner?' do
    assert(@event.owner?(@user))
  end

  test 'member?' do
    assert @event.member?(@user), "event.users = #{@event.users.first}"
  end

end

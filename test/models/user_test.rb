require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "first and last name should define display name" do
    @user = users(:one)
    assert_equal "User One", @user.display_name
  end

  test "user name should define display name" do
    @user = users(:two)
    assert_equal "user_two", @user.display_name
  end

  test "email should define display name" do
    @user = users(:three)
    assert_equal "user3@test.com", @user.display_name
  end

end

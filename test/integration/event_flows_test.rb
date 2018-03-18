require 'test_helper'
include Warden::Test::Helpers

class EventFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :one
    Warden.test_mode!
    login_as(@user, scope: :user)
    Event.create(name: "Test Event #1", owner_id: @user.id)
    Rails::logger.debug "User signed in"
  end


  test "should not allow duplicate event names for a user" do
  	assert_no_difference "Event.count" do
  		Event.create(name: "Test Event #1", owner_id: @user.id)
  	end
  end

end

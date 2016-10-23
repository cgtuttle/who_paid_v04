require 'test_helper'
include Warden::Test::Helpers

class UserFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :user_one
    Warden.test_mode!
    login_as(@user, scope: :user)
    Rails::logger.debug "User signed in"
  end

  test "can see the new user form" do
  	Rails::logger.debug "Testing..."

  	get "http://lvh.me:3000/users/new", {}, {'HTTP_REFERER' => "http://lvh.me:3000/users"}
  	assert_response :success
  end

end

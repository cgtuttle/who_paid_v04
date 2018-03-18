require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users :one
  end

  test "should create new user" do
  	# puts "#{User.count}"
    assert_difference ('User.count') do
    	post :create, user: {email: 'user4@test.com'} 
    end
    # puts "#{User.count}"

    assert_redirected_to users_path
  end

end
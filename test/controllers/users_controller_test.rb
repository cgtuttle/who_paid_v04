require 'test_helper'
include Devise::TestHelpers

class UsersControllerTest < ActionController::TestCase
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users :user_one
  end

  test "should create new user" do
  	puts "#{User.count}"
    assert_difference ('User.count') do
    	post :create, user: {email: 'user4@test.com'} 
    end
    puts "#{User.count}"
  end
end
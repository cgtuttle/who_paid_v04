require 'test_helper'
include Devise::TestHelpers

class PaymentsControllerTest < ActionController::TestCase
	setup do
		@event = events(:one)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users :user_one
    @payment = payments(:one)
  end

  test "should not save payment without a payer and payee" do
    payment = Payment.new
    assert_not payment.save, "Saved the payment without payer and payee"
  end

  test "should not delete payment without deleting transactions" do
  	flunk()
  end

end

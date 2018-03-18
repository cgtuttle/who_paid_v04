require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @event = events(:one)
    @event_id = @event.id
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in users :one
  end

  test "should get show" do
    Rails::logger.debug "event.id = #{@event_id}"
    get :show, {'id' => @event_id}
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create new event" do
    assert_difference ('Event.count') do  # creates event
      post :create, event: {name: 'Test Event'}
    end
    @test_event = Event.where(name: 'Test Event').first
    assert_equal @test_event.owner_id, users(:one).id  # sets event owner to current user
    assert_not_empty Account.where(source_id: @test_event.id, source_type: "Event") # account created for that event
    assert_equal @test_event.id, session[:current_event_id] # sets current_event to newly created event
    assert_redirected_to events_path  # redirects to events
    assert_equal 'Successfully created a new event.', flash[:notice]  # displays flash
  end

  test "should edit event" do
    get :edit, id: @event_id
    assert_response :success
  end

  test "should update event" do
    patch :update, id: @event_id, event: {name: @event.name}
    assert_redirected_to events_path
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event_id
    end
  end

end

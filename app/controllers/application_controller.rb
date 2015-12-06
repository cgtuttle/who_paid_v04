class ApplicationController < ActionController::Base

  include Pundit

  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    events_path
  end

  private

  def current_event
  	@current_event ||= session[:current_event_id] &&
  	Event.find_by(id: session[:current_event_id])
  end

  def set_current_event(event)
  	session[:current_event_id] = event.id
  end

  def reset_current_event
  	@current_event = session[:current_event_id] = nil
  end

end

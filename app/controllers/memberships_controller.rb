class MembershipsController < ApplicationController

	def create
		@event = Event.find(event_params)
		@membership = @event.memberships.new(user_id: user_params)
		if @membership.save
			redirect_to event_path(@event)
		end
	end

	def destroy
		@event = Event.find(event_params)
		@membership = @event.memberships.where(user_id: user_params).first
		if @membership.destroy
			redirect_to event_path(@event)
		end
	end


private

	def user_params
		params.require(:user_id)
	end

	def event_params
		params.require(:event_id)
	end

end

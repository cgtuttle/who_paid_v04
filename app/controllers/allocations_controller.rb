class AllocationsController < ApplicationController

	def update
		@account = Account.find(params[:account_id])
		redirect_to event_path(@account.event)
	end

private

	def allocation_params
		params.require(:allocation).permit(:allocation_method, :allocation_entry, :account_id, :journal_id, :journal_type)
	end

end
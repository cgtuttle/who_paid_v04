class PaymentsController < ApplicationController

  def new
  end

  def create
  end

  private

  def payments_params
    params.require(:payment).permit(:event_id, :payment_date, :account_from, :account_to, :amount, :for)
  end

end

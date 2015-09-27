class PaymentsController < ApplicationController

  def new
  end

  def create
    @payee_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payee_name]) do |account|
      account.source_type = "Payee"
    end
    @payer_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payer_name]) do |account|
      account.source_type = "Payer"
    end
    params[:payment][:account_to] = @payee_account.id
    params[:payment][:account_from] = @payer_account.id
    if @payment = current_event.payments.create!(payment_params)
      PaymentProcess.new(@payment).execute
      redirect_to event_path(current_event), notice: 'Successfully recorded a new payment'
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:event_id, :payment_date, :account_from, :account_to, :amount, :for, :payee_name, :payer_name)
  end

  def event_params
    params.require(:event_id)
  end

end

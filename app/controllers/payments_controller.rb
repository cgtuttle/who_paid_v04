class PaymentsController < ApplicationController

  def create
    @payee_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payee_name]) do |account|
      account.source_type = "User"
    end
    @payer_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payer_name]) do |account|
      account.source_type = "User"
    end
    params[:payment][:account_to] = @payee_account.id
    params[:payment][:account_from] = @payer_account.id
    if @payment = current_event.payments.create!(payment_params)
      PaymentProcess.new(@payment).execute
      redirect_to event_path(current_event), notice: 'Successfully recorded a new payment'
    end
  end

  def edit
    @event = current_event
    @event_payment = current_event.payments.find(params[:id])
    @event_payment.payer_name = Account.find(@event_payment.account_from).account_name
    @event_payment.payee_name = Account.find(@event_payment.account_to).account_name
  end

  def new
  end

  def set_delete
    @payment = Payment.find(params[:id])
    PaymentProcess.new(@payment).delete
    redirect_to event_path(current_event), notice: 'successfully deleted payment'
  end

  def update
    @payee_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payee_name]) do |account|
      account.source_type = "Payee"
    end
    @payer_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payer_name]) do |account|
      account.source_type = "Payer"
    end
    params[:payment][:account_to] = @payee_account.id
    params[:payment][:account_from] = @payer_account.id
    @payment = Payment.find(params[:id])
    @new_payment = current_event.payments.create!(payment_params)
    PaymentProcess.new(@new_payment).execute
    PaymentProcess.new(@payment).delete
    redirect_to event_path(current_event), notice: 'successfully updated payment'    
  end

  private

  def payment_params
    params.require(:payment).permit(:event_id, :payment_date, :account_from, :account_to, :amount, :for, :payee_name, :payer_name)
  end

  def event_params
    params.require(:event_id)
  end

end

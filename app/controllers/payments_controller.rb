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
    @payment = current_event.payments.new(payment_params)
    @payment.allocations.new(account_id: @payer_account.id)
    if @payment.save
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
    puts "Finding @payment"
    @payment = Payment.find(params[:id])
    puts "Executing PaymentProcess.delete"
    PaymentProcess.new(@payment).delete
    puts "Setting @payment.deleted"
    @payment.deleted = true
    puts "Saving @payment"
    @payment.save
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
    @payment.update(payment_params)
    PaymentProcess.new(@payment).update_allocations
    redirect_to event_path(current_event), notice: 'successfully updated payment'    
  end



  private

  def payment_params
    # params.require(:payment).permit(:payment_date, :account_from, :account_to, :amount, :for, :payee_name, :payer_name, :id, allocations_attributes: [:id, :_destroy, :account_id, :allocation_entry, :allocation_method])
    params.require(:payment).permit(:payment_date, :account_from, :account_to, :amount, :for, :payer_name, :payee_name, :id, allocations_attributes: [:id, :_destroy, :account_id, :allocation_entry, :allocation_method])
  end

  def event_params
    params.require(:event_id)
  end

end

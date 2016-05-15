class PaymentsController < ApplicationController

  def create
    set_account_from_param
    set_account_to_param
    params[:payment][:for] = "Settlement" unless params[:account_to_status] == "event_account"

    @payment = current_event.payments.new(payment_params)
    @payment.add_allocations
    if @payment.save
      PaymentProcess.new(@payment).execute
      redirect_to event_path(current_event), notice: 'Successfully recorded a new payment'
    end
  end

  def edit
    @event = current_event
    @user = current_user
    @event_payment = current_event.payments.find(params[:id])
  end

  def new
  end

  def set_delete
    @payment = Payment.find(params[:id])
    PaymentProcess.new(@payment).delete
    @payment.deleted = true
    @payment.save
    redirect_to event_path(current_event), notice: 'successfully deleted payment'
  end

  def update
    # @payee_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payee_name]) do |account|
    #   account.source_type = "Payee"
    # end
    # @payer_account = current_event.accounts.find_or_create_by(account_name: params[:payment][:payer_name]) do |account|
    #   account.source_type = "Payer"
    # end
    # params[:payment][:account_to] = @payee_account.id
    # params[:payment][:account_from] = @payer_account.id

    set_account_from_param
    set_account_to_param
    params[:payment][:for] = "Settlement" unless params[:account_to_status] == "event_account"

    @payment = Payment.find(params[:id])
    @payment.update(payment_params)
    PaymentProcess.new(@payment).update_allocations
    redirect_to event_path(current_event), notice: 'successfully updated payment'    
  end

  private

  def payment_params
    params.require(:payment).permit(:payment_date, :account_from, :account_to, :amount, :for, :id, :from_user_id,
      :to_user_id, allocations_attributes: [:id, :_destroy, :account_id, :allocation_entry, :allocation_method])
  end

  def event_params
    params.require(:event_id)
  end

  def set_account_from_param
    params[:payment][:account_from] = 
      define_accounts(
        params[:account_from_status], 
        params[:payment][:from_user_id], 
        params[:user_from][:email],
        params[:user_from][:first_name],
        params[:user_from][:last_name])
  end

  def set_account_to_param
    params[:payment][:account_to] = 
      define_accounts(
        params[:account_to_status], 
        params[:payment][:to_user_id], 
        params[:user_to][:email],
        params[:user_to][:first_name],
        params[:user_to][:last_name])
  end

  def define_accounts(source, id, email, first_name, last_name)
    case source
    when "event_account"
      account = current_event.accounts.where(source_type: "Event", source_id: current_event.id).first
    when "user_account"
      account = find_or_create_user_account(id)
    when "new_user_email"
      user = find_or_create_user(email.downcase, first_name, last_name)
      account = find_or_create_user_account(user.id)
    else
      user = create_user(first_name, last_name)
      account = find_or_create_user_account(user.id)
    end
    return account.id
  end

  def find_or_create_user_account(user_id)
    user = User.find(user_id)
    new_account = current_event.accounts.find_or_create_by(source_type: "User", source_id: user_id) do |account|
      account.source_type = "User"
      account.source_id = user_id
      account.account_name = user.display_name
    end
  end

  def find_or_create_user(email, first_name, last_name)
    email = email.downcase
    user = User.find_or_create_by(email: email) do |u|
      u.email = email
      u.first_name = first_name
      u.last_name = last_name
      u.role = "guest"
    end
  end

  def create_user(first_name, last_name)
    user = User.new(first_name: first_name, last_name: last_name, role: "guest")
    user.save
    user
  end

end

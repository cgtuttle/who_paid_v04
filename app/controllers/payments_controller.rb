class PaymentsController < ApplicationController

  def create

    @account_to_source = params[:account_to_status]
    @account_from_source = params[:account_from_status]

    case @account_to_source
    when "event_account"
      @payee_account = current_event.accounts.where(source_type: "Event", source_id: current_event.id).first
    when "user_account"
      @payee_account = find_or_create_user_account(params[:payment][:to_user_id])
    when "new_user_email"
      @user = find_or_create_user(params[:user_to][:email].downcase, params[:user_to][:first_name], params[:user_to][:last_name])
      @payee_account = find_or_create_user_account(@user.id)
    else
      @user = create_user(params[:user_to][:first_name], params[:user_to][:last_name])
      @payee_account = find_or_create_user_account(@user.id)
    end

    case @account_from_source
    when "event_account"
      @payer_account = current_event.accounts.where(source_type: "Event", source_id: current_event.id).first
    when "user_account"
      @payer_account = find_or_create_user_account(params[:payment][:from_user_id])
    when "new_user_email"
      @user = find_or_create_user(params[:user_from][:email].downcase, params[:user_from][:first_name], params[:user_from][:last_name])
      @payer_account = find_or_create_user_account(@user.id)
    else
      @user = create_user(params[:user_from][:first_name], params[:user_from][:last_name])
      @payer_account = find_or_create_user_account(@user.id)
    end

    # Assign accounts
    params[:payment][:account_to] = @payee_account.id
    params[:payment][:account_from] = @payer_account.id

    # Create payment
    @payment = current_event.payments.new(payment_params)
    @payment.add_allocations
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
    params.require(:payment).permit(:payment_date, :account_from, :account_to, :amount, :for, :id, :from_user_id,
      :to_user_id, allocations_attributes: [:id, :_destroy, :account_id, :allocation_entry, :allocation_method])
  end

  def event_params
    params.require(:event_id)
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

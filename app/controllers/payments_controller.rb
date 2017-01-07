class PaymentsController < ApplicationController

  def create
    params[:payment][:account_from] = assign_account("from")
    params[:payment][:account_to] = assign_account("to")
    if params[:payment][:to_user_id] != "" || params[:user_to][:first_name] != "" || params[:user_to][:last_name] != "" || params[:user_to][:email] != ""
      params[:payment][:for] = "Settlement"
    end
    @payment = current_event.payments.new(payment_params)
    if @payment.save
      @payment.add_allocations
      PaymentProcess.new(@payment).execute
      redirect_to event_path(current_event), notice: 'Successfully recorded a new payment'
    else
      flash[:notice] = 'Could not add the payment'
      render 'edit'
    end
  end

  def edit
    @title = "Edit payment"
    @event = current_event
    @user = current_user
    @payment = current_event.payments.find(params[:id])
  end

  def new
  end

  def set_delete
    @payment = Payment.find(params[:id])
    PaymentProcess.new(@payment).delete
    @payment.delete_allocations
    @payment.deleted = true
    @payment.save
    redirect_to event_path(current_event), notice: 'successfully deleted payment'
  end

  def update
    params[:payment][:account_from] = assign_account("from") if params[:payment][:account_from].blank?
    params[:payment][:account_to] = assign_account("to") if params[:payment][:account_to].blank?
    params[:payment][:for] = "Settlement" if not params[:payment][:to_user_id].blank?
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

  def assign_account(direction)
    id = params["payment"][direction + "_user_id"] # "payment"=>{"to_user_id"=>"5"}
    if params["payment"]["for"].present? && direction == "to"
      account = current_event.accounts.where(source_type: "Event", source_id: current_event.id).first
    elsif params["payment"][direction + "_user_id"] > "" # "payment"=>{"to_user_id"=>"5"}
      account = find_or_create_user_account(id)
    elsif params["user_" + direction].present?
      first_name = params["user_" + direction]["first_name"] || "" # "user_to"=>{"first_name"=>"john"}
      last_name = params["user_" + direction]["last_name"] || "" 
      if params["user_" + direction]["email"].present? # "user_to"=>{"email"=>"user@test.com"}
        email = params["user_" + direction]["email"]
        user = find_or_create_user(email.downcase, first_name, last_name)
      end
      account = find_or_create_user_account(user.id) if user
    end
    account.blank? ? false : account.id
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

class AccountsController < ApplicationController
  before_action :set_resources, except: [:destroy]

  def balances
  end

  def create
    @account = @event.accounts.new(account_params)
    if @account.save      
      redirect_to event_path(@event), notice:'Successfully added participant.'
    else
      redirect_to event_path(@event), alert:'Unable to add participant.'
    end
  end

  def destroy
  end

  def edit
  end

  def index
  end

  def new
    @account = @event.accounts.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def participants
  end

  def show
  end

  def statement
    @transactions = @account.statement_transactions
    @event = @account.event
    render 'statement'
  end

  def statement_email
    @transactions = @account.statement_transactions
    AccountMailer.statement_email(@user, @account, @transactions).deliver_now if @user
    redirect_to event_path(@event), notice:'Sent statement email.'
  end

  def statements_email
    @participants = @event.participants
    @user = current_user
    @participants.each do |p|
      AccountMailer.statement_email(@user, p, p.statement_transactions).deliver_now
    end
    redirect_to event_path(@event), notice:'Sent statement email.'    
  end

  def update
  end

  private

  def set_resources
    if params[:account_id]
      @account = Account.find(params[:account_id])
      @user = User.find(@account.source_id) if @account.source_type = "User"
    end
    @event = Event.find(params[:event_id])
    @accounts = @event_accounts
  end

  def account_params
    params.require(:account).permit(:account_name, :source_id, :source_type)
  end

end

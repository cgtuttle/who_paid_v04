class AccountsController < ApplicationController
  before_action :set_resources

  def balances
  end

  def create
    @account = Account.new(account_params)
    @event = Event.find(account_params)
    if @account.save      
      redirect_to event_path(@event), notice:'Successfully added participant.'
    else
      redirect_to event_path(@event), alert:'Unable to add participant.'
    end
  end

  def destroy
    # @account = Account.find(params[:id])
    if AccountProcess.new(@account).delete
      redirect_to event_path(@event), notice:'Successfully deleted participant.'
    else
      redirect_to event_path(@event), notice:'Unable to delete participant.'
    end
  end

  def edit
    @account = Account.find(params[:id]) 
  end

  def index
  end

  def new
    @account = Account.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @title = "Add a payment..."
    @account = Account.find(params[:id])
    @payment = @account.payments.new
    @payments = @account.payments
    @transactions = @account.account_transactions.order(occurred_on: :desc)
  end

  def statement
    @transactions = @account.statement_transactions
    render 'statement'
  end

  def event_statement
    # @transactions = AccountTransaction.includes(:source)
    @transactions = @account.statement_transactions    
    render 'event_statement'
  end

  def statement_email
    @transactions = @account.statement_transactions
    AccountMailer.statement_email(@user, @account, @transactions).deliver_now if @user
    redirect_to event_path(@event), notice:'Sent statement email.'
  end

  def statements_email
    @participants = @event.users
    @user = current_user
    @participants.each do |p|
      AccountMailer.statement_email(@user, p, p.statement_transactions).deliver_now
    end
    redirect_to event_path(@event), notice:'Sent statement email.'    
  end

  def update
    @account = Account.find(params[:id])
    @account.update(account_params)
    if @event.save  
      redirect_to event_path(@event), notice: 'Successfully updated account.'
    else
      render action: 'edit', notice: 'Unable to update account'
    end
  end

  private

  def set_resources
    if params[:account_id]
      @account = Account.find(params[:account_id])
      @user = User.find(@account.source_id) if @account.source_type == "User"
      @event = current_event
      logger.debug "set_resources: @account = #{@account}"
    end
  end

  def account_params
    params.require(:account).permit(:name, :source_id, :source_type, :active, :default_share, :default_method, :event_id)
  end

end

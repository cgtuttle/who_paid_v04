class AccountsController < ApplicationController

  def create
    @event = Event.find(event_params)
    @account = @event.accounts.new(account_params)
    @account.source_type = "User"
    if @account.save
      redirect_to event_path(@event), notice:'Successfully added user.'
    else
      redirect_to event_path(@event), alert:'Unable to add user.'
    end
  end

  def destroy
  end

  def edit
  end

  def index
    @event = Event.find(event_params)
    @accounts = @event.accounts
    logger.debug "@accounts = #{@accounts}"
  end

  def new
    @event = Event.find(event_params)
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

  def update
  end

  private

  def account_params
    params.require(:account).permit(:account_name, :source_id, :source_type)
  end

  def event_params
    params.require(:event_id)
  end

end

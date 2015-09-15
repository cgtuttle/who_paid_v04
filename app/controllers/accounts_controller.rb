class AccountsController < ApplicationController

  def create
    @event = Event.find(event_params)
    @account = @event.accounts.new(source_id: params[:source_id], source_type: params[:source_type], name: params[:name])
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
    respond_to do |format|
      format.html
      format.json { render json: @accounts}
    end
  end

  def new
  end

  def participants
  end

  def show
  end

  def update
  end

  private

  def event_params
    params.require(:event_id)
  end

end

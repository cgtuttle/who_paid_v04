class EventsController < ApplicationController
  before_action :set_resources, :only => [:edit, :show, :new, :destroy, :update]
  before_filter :authenticate_user!
  before_filter :authorize_action, :only => [:edit, :new, :show, :update, :destroy]
  before_filter :scope_policy, :only => :index
  after_action :verify_authorized, :except => [:index, :audit]
  after_action :verify_policy_scoped, :only => :index

  def create
    @event = Event.new(event_params)
    authorize @event
    @event.owner_id = current_user.id
    if @event.save
      @event.create_event_owner_account(current_user)
      @event.create_event_default_account
      set_current_event(@event)
      redirect_to events_path, notice:'Successfully created a new event.'
    end
  end

  def destroy
    if @event.destroy
      redirect_to events_path, notice:'Successfully deleted event.'
    else
      redirect_to events_path, alert: 'Must be owner or admin to delete'
    end
  end

  def edit
  end

  def index
    reset_current_event
  end

  def new
    @event = Event.new
  end

  def show
    set_current_event(@event)
    @participants = @event.participants
    @friends = current_user.all_friends - @event.users
    @payments = @event.payments.active.order(:payment_date, :created_at)
    @new_event_payment = @event.payments.new
  end

  def update
    set_current_event(@event)
    @event.update(event_params)
    if @event.save  
      redirect_to events_path, notice: 'Successfully updated event.'
    else
      render action: 'edit', notice: 'Unable to update event'
    end
  end

  private

  def set_resources
    if params[:id]
      if Event.exists?(params[:id])
        @event = Event.find(params[:id])
      else
        redirect_to events_path
      end
    else
      logger.debug "Setting new event"
      @event = Event.new
    end
  end

  def authorize_action
    authorize @event
    logger.info "Authorizing event #{@event.name}"
  end

  def scope_policy
    @events = policy_scope(Event)
    logger.info "Policy scoping Event"
  end

  def event_params
    params.require(:event).permit(:name)
  end

end

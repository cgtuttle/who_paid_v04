class EventsController < ApplicationController
  before_action :set_resources, :only => [:edit, :show, :new, :destroy, :update]
  before_filter :authenticate_user!
  before_filter :authorize_action, :only => [:edit, :new, :show, :update, :destroy]
  before_filter :scope_policy, :only => :index
  after_action :verify_authorized, :except => [:index, :audit]
  after_action :verify_policy_scoped, :only => :index
  before_action :get_config_vars

  def create
    @event = Event.new(event_params)
    authorize @event
    @event.owner_id = current_user.id
    if @event.save
      @event.create_account(name: @event.name)
      @event.memberships.create(user: current_user)
      set_current_event(@event)
      redirect_to events_path, notice:'Successfully created a new event.'
    else
      render :new
    end
  end

  def destroy
    @event.payments.update_all event_id: nil
    if @event.destroy
      redirect_to events_path, notice:'Successfully deleted event.'
    else
      redirect_to events_path, alert: 'Must be owner or admin to delete'
    end
  end

  def edit
  end

  def index
    # Set session:current_event to nil
    reset_current_event
  end

  def new
    @event = Event.new
  end

  def show
    @title = "Add a payment"
    set_current_event(@event)
    @participants = @event.users
    @friends = current_user.all_friends - @event.users
    @payments = @event.payments.active.order(:payment_date, :created_at)
    @payment = @event.payments.new
    @transactions = @event.account.statement_transactions
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
    logger.info "Policy scoping Event"
    @events = policy_scope(Event)
  end

  def get_config_vars
    @create_reversals = Rails.application.config_for(:process)["create_reversals"]
    @delete_payments = Rails.application.config_for(:process)["delete_payments"]
  end

  def event_params
    params.require(:event).permit(:name)
  end

end

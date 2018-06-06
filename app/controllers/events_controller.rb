class EventsController < ApplicationController
  before_action :find_event, only: [:show, :edit, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show, :home]
  def home
    @events1 = Event.all
    @events1 = policy_scope(Event).order(created_at: :desc)
    @events = @events1.first(3)
    raise
  end

  def index
    if params[:date].present?
      @events = Event.where(date: params[:date])
      @events = policy_scope(Event).order(created_at: :desc)
      events_marker = @events.where.not(latitude: nil, longitude: nil)
      @markers = events_marker.map do |event|
        {
          lat: event.latitude,
          lng: event.longitude,
        }
      end
      #sql_query = " \
      #  events.date @@ :query \
      #  OR events.price @@ :query \
      #{}"
      # @events = Event.where(sql_query, query: "%#{params[:query]}%")
    else
      
      @events = Event.all
      @events = policy_scope(Event).order(created_at: :desc)
      events_marker = @events.where.not(latitude: nil, longitude: nil)
      @markers = events_marker.map do |event|
        {
          lat: event.latitude,
          lng: event.longitude,
        }
      end
    end
  end

  def show
    # @user = User.find(current_user.id)
    authorize @event
  end


  def new
    @event = Event.new
    authorize @event
  end

  def edit
  end

  def create
    @event = Event.new(event_params)
    authorize @event
    if @event.save
      redirect_to event_path(@event)
    else
      render :new
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.update(event_params)
    if @event.save
      redirect_to event_path(@event)
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end

  private

  def find_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :address, :date, :time, :min_p, :max_p, :description, :photo)
  end

end

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @events = Event.all
    @ongoing_events_count = Event.where("start_date <= ? AND end_date >= ?", Time.current, Time.current).count
  end

  def show
    @attendance = Attendance.new
    @is_participant = @event.attendances.exists?(user_id: current_user.id) if user_signed_in?

    # Récupérer le nombre de participants pour cet événement
    @participant_count = @event.attendances.count

    # Récupérer le nombre total d'événements en cours
    @ongoing_events_count = Event.where("start_date <= ? AND end_date >= ?", Time.current, Time.current).count
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    if @event.save
      redirect_to @event, notice: 'Événement créé avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Événement mis à jour.'
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Événement supprimé.'
  end

  private

  def authorize_user!
    unless @event.user_id == current_user.id || current_user.admin?
      redirect_to events_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette page."
    end
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :location, :price, :start_date, :duration)
  end
end

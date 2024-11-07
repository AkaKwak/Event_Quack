class EventsController < ApplicationController
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @events = Event.all
  end

  def show
    @attendance = Attendance.new
  end

  def new
    @event = Event.new
  end

  def create
    # request.format = :html
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

  def participant?(user)
    participants.include?(user)
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

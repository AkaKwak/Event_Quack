class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

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
    @event.user = User.first # Utilisateur par défaut pour le moment, jusqu'à l'implémentation de Devise

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

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :location, :price, :start_date, :duration)
  end
end

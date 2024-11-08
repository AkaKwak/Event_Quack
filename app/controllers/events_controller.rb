class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @events = Event.all
    @ongoing_events_count = Event.where("start_date >= ?", Time.current).where.not(end_date: nil).count
  end

  def show
    @attendance = Attendance.new
    @is_participant = @event.attendances.exists?(user_id: current_user.id) if user_signed_in?
    @participant_count = @event.attendances.count
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    current_user.role = 'author'
    current_user.save if current_user.changed?

    # Vérifiez que la durée est fournie
    if @event.start_date.present? && @event.duration.present?
      @event.end_date = @event.start_date + @event.duration.minutes
    else
      @event.errors.add(:base, "La date de début et la durée doivent être fournies.")
      render :new and return
    end
  
    # Assurez-vous que l'événement n'est pas déjà passé
    if @event.start_date < Time.current
      @event.errors.add(:base, "La date de début ne peut pas être dans le passé.")
      render :new and return
    end
  
    # Tentez de sauvegarder l'événement
    if @event.save
      redirect_to events_path, notice: 'Événement créé avec succès.'
    else
      puts "Erreurs lors de la création de l'événement : #{@event.errors.full_messages.join(', ')}" # Pour le debugging
      render :new  # Affiche le formulaire à nouveau avec les messages d'erreur
    end
  end

  def edit
    @event = Event.find(params[:id]) # Récupération de l'événement à modifier
    # La vue 'edit' affichera le formulaire pour modifier cet événement
  end
  

  def update
    @event = Event.find(params[:id]) # Récupération de l'événement à modifier
    if @event.update(event_params) # Mise à jour des attributs de l'événement avec les paramètres du formulaire
      redirect_to @event, notice: 'Événement mis à jour.' # Redirection vers la page de l'événement après succès
    else
      render :edit # Rappel du formulaire d'édition en cas d'erreur
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

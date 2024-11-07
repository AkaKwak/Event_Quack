class AttendancesController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])

    # Vérification si l'utilisateur est déjà inscrit
    if @event.attendances.exists?(user: current_user)
      redirect_to @event, alert: "Vous êtes déjà inscrit à cet événement."
      return
    end

    @attendance = @event.attendances.new(user: current_user)

    if @attendance.save
      redirect_to @event, notice: "Vous avez rejoint l'événement."
    else
      redirect_to @event, alert: "Impossible de rejoindre l'événement."
    end
  end
end

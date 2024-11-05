class AttendancesController < ApplicationController
  def create
    @event = Event.find(params[:event_id])
    @attendance = @event.attendances.new(user: User.first) # Utilisateur par défaut pour le moment
    @attendance.stripe_customer_id = "test_customer_id"

    if @attendance.save
      redirect_to @event, notice: "Vous avez rejoint l'événement."
    else
      redirect_to @event, alert: "Impossible de rejoindre l'événement."
    end
  end
end

class AttendancesController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    
    # Débogage : affichage des informations sur l'utilisateur et l'événement
    puts "Current User ID: #{current_user.id}"
    puts "Event ID: #{@event.id}"
    
    # Vérification si l'utilisateur est déjà inscrit
    if @event.attendances.exists?(user: current_user)
      puts "Attendance exists for User ID: #{current_user.id} and Event ID: #{@event.id}"
      redirect_to @event, alert: "Vous êtes déjà inscrit à cet événement."
      return
    end

    @attendance = @event.attendances.new(user: current_user)

    if @attendance.save
      puts "Attendance created successfully for User ID: #{current_user.id} and Event ID: #{@event.id}"
      redirect_to @event, notice: "Vous avez rejoint l'événement."
    else
      puts "Failed to create attendance for User ID: #{current_user.id} and Event ID: #{@event.id}"
      puts @attendance.errors.full_messages # Ajoute cette ligne pour afficher les erreurs
      redirect_to @event, alert: "Impossible de rejoindre l'événement."
    end
  end
end

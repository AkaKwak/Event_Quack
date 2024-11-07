class AttendancesController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])

    # Vérifiez si l'événement est déjà passé
    if @event.end_date < Time.current
      redirect_to @event, alert: "Cet événement est déjà passé et ne peut plus être rejoint."
      return
    end

    # Vérifiez si l'utilisateur est déjà participant
    if @event.attendances.exists?(user_id: current_user.id)
      redirect_to @event, alert: "Vous êtes déjà inscrit à cet événement."
      return
    end

    # Crée une session Stripe
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: {
            name: @event.title,
            description: @event.description,
            images: ["https://example.com/image.png"], # Vous pouvez ajouter une image ici
          },
          unit_amount: (@event.price * 100), # Convertir en centimes
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}", # Mettez à jour le chemin
      cancel_url: "#{checkout_cancel_url}?session_id={CHECKOUT_SESSION_ID}",
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    # Logique après un paiement réussi
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @attendance = Attendance.new(user: current_user, event_id: session.metadata.event_id, stripe_customer_id: session.customer)

    if @attendance.save
      redirect_to event_path(session.metadata.event_id), notice: "Vous avez rejoint l'événement."
    else
      redirect_to events_path, alert: "Erreur lors de l'inscription."
    end
  end
  
  def cancel
    redirect_to events_path, alert: "Le paiement a été annulé."
  end
end
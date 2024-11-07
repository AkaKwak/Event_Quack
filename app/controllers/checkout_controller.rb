class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    if @event.end_date < Time.current
      redirect_to @event, alert: "Cet événement est déjà passé."
      return
    end

    if @event.attendances.exists?(user_id: current_user.id)
      redirect_to @event, alert: "Vous êtes déjà inscrit à cet événement."
      return
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: {
            name: @event.title,
            description: @event.description,
            images: ["https://example.com/image.png"],
          },
          unit_amount: (@event.price * 100),
        },
        quantity: 1,
      }],
      mode: 'payment',
      metadata: {
        event_id: @event.id
      },
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{checkout_cancel_url}?session_id={CHECKOUT_SESSION_ID}",
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    # Récupérer la session Stripe
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    Rails.logger.debug "Stripe Session: #{session.inspect}"
  
    # Récupérer l'ID de l'événement depuis les métadonnées de la session
    event_id = session.metadata['event_id']
  
    # Vérifiez si l'ID de l'événement est présent
    if event_id.nil?
      Rails.logger.error "L'ID de l'événement est manquant dans les métadonnées de la session."
      redirect_to events_path, alert: "Erreur lors de la récupération des informations de l'événement."
      return
    end
  
    @event = Event.find(event_id)
  
    # Vérifiez d'abord si l'utilisateur est déjà inscrit
    existing_attendance = Attendance.find_by(user_id: current_user.id, event_id: @event.id)
  
    if existing_attendance
      redirect_to event_path(@event), alert: "Vous êtes déjà inscrit à cet événement."
      return
    end
  
    # Récupérer l'ID du client Stripe
    stripe_customer_id = session.customer
  
    # Si aucun client Stripe n'a été créé, créez-en un
    if stripe_customer_id.nil?
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: current_user
      )
      stripe_customer_id = customer.id
    end
  
    # Créer une nouvelle participation
    attendance = Attendance.new(
      user: current_user,
      event: @event,
      stripe_customer_id: stripe_customer_id
    )
  
    if attendance.save
      redirect_to event_path(@event), notice: "Votre participation a été enregistrée avec succès!"
    else
      Rails.logger.error "Erreur lors de la création de la participation: #{attendance.errors.full_messages}"
      redirect_to events_path, alert: "Une erreur est survenue lors de l'enregistrement de votre participation."
    end
  end
end

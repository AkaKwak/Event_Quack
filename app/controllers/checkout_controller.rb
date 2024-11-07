class CheckoutController < ApplicationController
  def create
    @total = params[:total].to_d
    @event_id = params[:event_id]
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'eur',
            unit_amount: (@total*100).to_i,
            product_data: {
              name: 'Rails Stripe Checkout',
            },
          },
          quantity: 1
        },
      ],
      mode: 'payment',
      metadata: {
        event_id: @event_id
      },
      success_url: checkout_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: checkout_cancel_url
    )
    redirect_to @session.url, allow_other_host: true
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)
    @event_id = @session.metadata.event_id
  
    # Vérifie si l'utilisateur est connecté
    if current_user
      # Vérifie si l'utilisateur est déjà inscrit à l'événement
      existing_attendance = Attendance.find_by(user_id: current_user.id, event_id: @event_id)
      if existing_attendance
        flash[:notice] = "Vous êtes déjà inscrit à cet événement."
        redirect_to event_path(@event_id) and return
      end
  
      # Crée une nouvelle participation
      attendance = Attendance.new(user: current_user, event_id: @event_id, stripe_customer_id: @session.customer)
  
      if attendance.save
        flash[:notice] = "Vous avez rejoint l'événement avec succès."
      else
        # Gère les erreurs de création de participation
        flash[:alert] = "Erreur lors de l'inscription à l'événement : #{attendance.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "Vous devez être connecté pour rejoindre un événement."
    end
  end
  

  def cancel
  end
end

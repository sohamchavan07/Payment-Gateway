class PaymentsController < ApplicationController
    def new
    end

    def create_payment_intent
      amount = params[:amount]
      currency = params[:currency] || "inr"
      order_id = params[:order_id]
      full_name = params[:full_name]

    # Validate amount only; order_id is optional metadata
    if amount.blank?
      render json: { error: "amount is required" }, status: :unprocessable_entity
        return
    end

      begin
      metadata = { full_name: full_name }
      metadata[:order_id] = order_id if order_id.present?

      intent = Stripe::PaymentIntent.create(
        amount: amount.to_i,
        currency: currency.to_s.downcase,
        metadata: metadata
      )
      rescue Stripe::StripeError => e
        render json: { error: e.message }, status: :bad_request
        return
      end

      render json: { id: intent.id, client_secret: intent.client_secret, status: intent.status }
    end

    def create_checkout_session
      session = Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        mode: "payment",
        line_items: [ {
          price_data: {
            currency: "usd",
            product_data: { name: "Test Product" },
            unit_amount: 2000 # $20.00
          },
          quantity: 1
        } ],
        success_url: root_url + "?success=true",
        cancel_url: root_url + "?canceled=true"
      )
      redirect_to session.url, allow_other_host: true
    end
end

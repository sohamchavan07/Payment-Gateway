class Api::V1::SubscriptionPlansController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    payload = params.permit(:user_id, :plan_id, :payment_method_token)
    unless payload[:user_id].present? && payload[:plan_id].present?
      render json: { error: "user_id and plan_id are required" }, status: :unprocessable_entity
      return
    end

    begin
      # For demo: create a Stripe customer and subscription
      customer = Stripe::Customer.create(metadata: { user_id: payload[:user_id] })

      if payload[:payment_method_token].present?
        Stripe::PaymentMethod.attach(payload[:payment_method_token], { customer: customer.id })
        Stripe::Customer.update(customer.id, { invoice_settings: { default_payment_method: payload[:payment_method_token] } })
      end

      subscription = Stripe::Subscription.create(
        customer: customer.id,
        items: [ { price: payload[:plan_id] } ]
      )

      render json: { subscription_id: subscription.id, status: subscription.status }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end

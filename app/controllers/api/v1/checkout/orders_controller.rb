class Api::V1::Checkout::OrdersController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    payload = params.permit(:user_id, :currency, shipping_address: {}, items: [ :sku, :qty, :price ])

    items = Array(payload[:items]).map do |i|
      {
        sku: i[:sku],
        qty: i[:qty].to_i,
        price: i[:price].to_f
      }
    end

    if items.empty?
      render json: { error: "items are required" }, status: :unprocessable_entity
      return
    end

    currency = (payload[:currency] || "INR").to_s.upcase
    amount_cents = items.sum do |i|
      (i[:price].to_f * 100.0).round * i[:qty].to_i
    end
    Rails.logger.warn("[Checkout#create] items=#{items.inspect} amount_cents=#{amount_cents}")

    order = Order.create!(
      amount_cents: amount_cents,
      currency: currency,
      status: "created",
      line_items: items,
      metadata: { user_id: payload[:user_id], shipping_address: payload[:shipping_address] }
    )

    intent = Stripe::PaymentIntent.create(
      amount: order.amount_cents,
      currency: order.currency.downcase,
      metadata: { order_id: order.id }
    )

    order.update!(payment_intent_id: intent.id)

    response_payload = {
      order_id: order.id,
      amount: order.amount_cents,
      currency: order.currency,
      payment_client_token: intent.client_secret
    }
    response_payload[:debug] = { items: items, amount_cents: amount_cents } if Rails.env.test?
    render json: response_payload
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :bad_request
  end
end

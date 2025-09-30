class Api::V1::Checkout::PaymentsController < ApplicationController
  protect_from_forgery with: :null_session

  def confirm
    payload = params.permit(:order_id, :payment_provider_id, :payment_method_token)

    unless payload[:order_id].present?
      render json: { error: "order_id is required" }, status: :unprocessable_entity
      return
    end

    order = Order.find_by(id: payload[:order_id])
    unless order
      render json: { error: "order not found" }, status: :not_found
      return
    end

    begin
      # Optionally verify provider intent matches
      if payload[:payment_provider_id].present? && order.payment_intent_id.present? && payload[:payment_provider_id] != order.payment_intent_id
        render json: { error: "payment provider id mismatch" }, status: :unprocessable_entity
        return
      end

      # Confirm via Stripe if needed
      if order.payment_intent_id.present?
        Stripe::PaymentIntent.confirm(order.payment_intent_id, { payment_method: payload[:payment_method_token] }.compact)
      end

      order.update!(status: "paid")

      render json: {
        order_id: order.id,
        status: order.status,
        payment_id: order.payment_intent_id
      }
    rescue Stripe::StripeError => e
      order.update!(status: "payment_failed", metadata: (order.metadata || {}).merge(error: e.message))
      render json: { error: e.message }, status: :bad_request
    end
  end
end

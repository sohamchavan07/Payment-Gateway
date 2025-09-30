class Api::V1::Admin::RefundsController < ApplicationController
  protect_from_forgery with: :null_session
  # TODO: add authentication/authorization for admin

  def create
    payload = params.permit(:payment_id, :amount, :reason, :idempotency_key)
    unless payload[:payment_id].present? && payload[:amount].present?
      render json: { error: "payment_id and amount are required" }, status: :unprocessable_entity
      return
    end

    begin
      refund = Stripe::Refund.create({
        payment_intent: payload[:payment_id],
        amount: payload[:amount].to_i,
        reason: payload[:reason]
      }.compact, { idempotency_key: payload[:idempotency_key] }.compact)

      render json: { refund_id: refund.id, status: refund.status }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :bad_request
    end
  end
end

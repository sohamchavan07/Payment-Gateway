class WebhooksController < ApplicationController
    protect_from_forgery except: :stripe

    def stripe
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
        )
      rescue JSON::ParserError, Stripe::SignatureVerificationError
        head :bad_request
        return
      end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      Rails.logger.info "Payment success for session: #{session.id}"
    when "payment_intent.succeeded"
      payment_intent = event.data.object
      order_id = payment_intent.metadata&.[]("order_id")
      order = Order.find_by(id: order_id)
      if order
        order.update(status: "paid")
      else
        Rails.logger.warn "Order not found for PI #{payment_intent.id}"
      end
    when "payment_intent.payment_failed"
      payment_intent = event.data.object
      order_id = payment_intent.metadata&.[]("order_id")
      order = Order.find_by(id: order_id)
      order&.update(status: "failed")
    end

      head :ok
    end
end

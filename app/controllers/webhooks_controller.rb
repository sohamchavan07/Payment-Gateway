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
      metadata = payment_intent.metadata || {}
      order_id = metadata["order_id"]
      order = ::Order.find_by(id: order_id) || ::Order.find_by(payment_intent_id: payment_intent.id)
      if order
        order.update(status: "paid")
      else
        Rails.logger.warn "Order not found for PI #{payment_intent.id}"
      end
    when "payment_intent.payment_failed"
      payment_intent = event.data.object
      metadata = payment_intent.metadata || {}
      order_id = metadata["order_id"]
      order = ::Order.find_by(id: order_id) || ::Order.find_by(payment_intent_id: payment_intent.id)
      order&.update(status: "failed")
    when "refund.created", "refund.succeeded"
      refund = event.data.object
      payment_intent_id = refund.respond_to?(:payment_intent) ? refund.payment_intent : nil
      order = ::Order.find_by(payment_intent_id: payment_intent_id)
      if order
        order_metadata = (order.metadata || {}).deep_dup
        refunds_log = (order_metadata["refunds"] || [])
        refunds_log << {
          id: refund.id,
          amount: refund.amount,
          currency: refund.currency,
          status: refund.status,
          reason: refund.reason,
          created: refund.created
        }.compact
        order_metadata["refunds"] = refunds_log

        new_status = event.type == "refund.succeeded" ? "refunded" : (order.status || "paid")
        order.update(status: new_status, metadata: order_metadata)
      else
        Rails.logger.warn "Order not found for refund #{refund.id} (PI #{payment_intent_id})"
      end
    when "charge.refunded"
      charge = event.data.object
      payment_intent_id = charge.respond_to?(:payment_intent) ? charge.payment_intent : nil
      order = ::Order.find_by(payment_intent_id: payment_intent_id)
      if order
        order_metadata = (order.metadata || {}).deep_dup
        refunds_log = (order_metadata["refunds"] || [])
        refunds_log << {
          charge_id: charge.id,
          amount_refunded: charge.amount_refunded,
          currency: charge.currency,
          fully_refunded: charge.refunded
        }.compact
        order_metadata["refunds"] = refunds_log
        order.update(status: "refunded", metadata: order_metadata)
      else
        Rails.logger.warn "Order not found for refunded charge #{charge.id} (PI #{payment_intent_id})"
      end
    end

      head :ok
    end
end

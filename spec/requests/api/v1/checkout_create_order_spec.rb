require 'rails_helper'

RSpec.describe "POST /api/v1/checkout/create-order", type: :request do
  let(:stripe_intent_id) { "pi_123" }
  let(:stripe_client_secret) { "pi_123_secret_abc" }

  before do
    allow(Stripe::PaymentIntent).to receive(:create).and_return(
      double(id: stripe_intent_id, client_secret: stripe_client_secret)
    )
  end

  it "creates order and returns expected JSON" do
    payload = {
      user_id: nil,
      items: [ { sku: "SKU1", qty: 1, price: 499.0 } ],
      shipping_address: { line1: "123 Main St" },
      currency: "INR"
    }

    post "/api/v1/checkout/create-order", params: payload

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    puts "DEBUG RESPONSE: #{json}"
    expect(json["order_id"]).to be_present
    expect(json["amount"]).to eq(49900)
    expect(json["currency"]).to eq("INR")
    expect(json["payment_client_token"]).to eq(stripe_client_secret)

    order = Order.find(json["order_id"]) rescue nil
    expect(order).to be_present
    expect(order.amount_cents).to eq(49900)
    expect(order.currency).to eq("INR")
    expect(order.payment_intent_id).to eq(stripe_intent_id)
  end

  it "validates presence of items" do
    post "/api/v1/checkout/create-order", params: { items: [] }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

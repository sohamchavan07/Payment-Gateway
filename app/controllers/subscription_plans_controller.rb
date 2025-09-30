class SubscriptionPlansController < ApplicationController
  def index
    # In absence of a DB model, build plans from env/Stripe metadata
    configured_plans = [
      { id: ENV["STRIPE_PRICE_BASIC"], name: "Basic", description: "For individuals", amount_in_currency: 199.00, interval: "month", formatted_interval: "monthly" },
      { id: ENV["STRIPE_PRICE_PRO"], name: "Pro", description: "For teams", amount_in_currency: 499.00, interval: "month", formatted_interval: "monthly" }
    ].compact.select { |p| p[:id].present? }

    @subscription_plans = configured_plans.map do |p|
      OpenStruct.new(p)
    end
  end
end

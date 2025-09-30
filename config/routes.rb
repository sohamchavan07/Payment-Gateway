Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "workshop#new"

  get "/workshop", to: "workshop#new"
  get "/payments/new", to: "payments#new", as: :new_payment

  # Subscriptions UI
  get "/subscriptions", to: "subscriptions#index", as: :subscriptions
  get "/subscriptions/new", to: "subscriptions#new", as: :new_subscription

  # Subscription plans listing UI
  get "/subscription_plans", to: "subscription_plans#index", as: :subscription_plans

  post "/create-checkout-session", to: "payments#create_checkout_session"
  post "/payment_intents", to: "payments#create_payment_intent"
  post "/webhooks/stripe", to: "webhooks#stripe"

  namespace :api do
    namespace :v1 do
      namespace :checkout do
        post "/create-order", to: "orders#create"
        post "/confirm-payment", to: "payments#confirm"
      end

      # User cards
      post "/users/:id/save-card", to: "users/cards#create"
      get "/users/:id/cards", to: "users/cards#index"

      # Subscriptions
      post "/subscriptions/create", to: "subscriptions#create"

      # Admin
      post "/admin/refund", to: "admin/refunds#create"
    end
  end
end

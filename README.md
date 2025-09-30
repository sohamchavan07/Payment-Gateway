## Payment Gateway (Rails + Stripe)

Minimal Rails app demonstrating Stripe PaymentIntent flow with a card form using Stripe Elements.

### Prerequisites
- Ruby and Bundler installed
- SQLite (default) or your preferred DB
- Stripe account and API keys

### Setup
```bash
cd payment_gateway
bundle install

# Create and migrate database
bin/rails db:setup
```

### Configure Stripe
Set your Stripe keys via environment variables or Rails credentials.

Environment variables (development example):
```bash
export STRIPE_PUBLISHABLE_KEY=pk_test_...
export STRIPE_SECRET_KEY=sk_test_...
```

Alternatively, add them to Rails credentials and load in `config/initializers/stripe.rb`.

### Run the app
```bash
bin/rails server
# App runs at http://localhost:3000
```

Open the demo form:
- http://localhost:3000/payments/new

### Creating a PaymentIntent (client flow)
The view `app/views/payments/new.html.erb` renders Stripe Elements and posts to your `PaymentIntents` endpoint to create a PaymentIntent, then confirms it on the client.

### Webhooks (recommended)
Use Stripe CLI to forward webhooks to your local server (adjust port as needed):
```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

Ensure your `WebhooksController` verifies events and updates your business state as needed.

### Testing
Use Stripe test card numbers, e.g. 4242 4242 4242 4242 with any future expiry and any CVC.

### Useful Rake/rails commands
```bash
bin/rails routes | cat
bin/rails db:migrate
bin/rails db:rollback
```

### Notes
- Ensure `STRIPE_PUBLISHABLE_KEY` is available to the client-side (the view references it).
- `STRIPE_SECRET_KEY` must never be exposed to the client; it is used server-side.
- For production, configure credentials and HTTPS, and set up your webhook endpoint in the Stripe Dashboard.

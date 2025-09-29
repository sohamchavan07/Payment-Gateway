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


/Users/shdc02/soham_workspace/Payment-Gateway/
  - payment_gateway/
    - app/
      - assets/
        - images/
        - stylesheets/
          - application.css
      - controllers/
        - api/
          - v1/
            - checkout/
              - orders_controller.rb
        - application_controller.rb
        - concerns/
        - payments_controller.rb
        - webhooks_controller.rb
        - workshop_controller.rb
      - helpers/
        - application_helper.rb
      - javascript/
        - application.js
        - controllers/
          - application.js
          - hello_controller.js
          - index.js
      - jobs/
        - application_job.rb
      - mailers/
        - application_mailer.rb
      - models/
        - application_record.rb
        - concerns/
        - order.rb
      - views/
        - layouts/
          - application.html.erb
          - mailer.html.erb
          - mailer.text.erb
        - payments/
          - new.html.erb
        - pwa/
          - manifest.json.erb
          - service-worker.js
        - workshop/
          - new.html.erb
    - bin/
      - brakeman
      - bundle
      - dev
      - docker-entrypoint
      - importmap
      - jobs
      - kamal
      - rails
      - rake
      - rubocop
      - setup
      - thrust
    - Booting
    - config/
      - application.rb
      - boot.rb
      - cable.yml
      - cache.yml
      - credentials.yml.enc
      - database.yml
      - deploy.yml
      - environment.rb
      - environments/
        - development.rb
        - test.rb
      - importmap.rb
      - initializers/
        - assets.rb
        - content_security_policy.rb
        - filter_parameter_logging.rb
        - inflections.rb
        - stripe.rb
      - locales/
        - en.yml
      - puma.rb
      - queue.yml
      - recurring.yml
      - routes.rb
      - storage.yml
    - config.ru
    - db/
      - cable_schema.rb
      - cache_schema.rb
      - migrate/
        - 20250925143554_create_orders.rb
        - 20250926131732_add_payment_intent_id_to_orders.rb
      - queue_schema.rb
      - schema.rb
      - seeds.rb
    - Dockerfile
    - Gemfile
    - Gemfile.lock
    - lib/
      - tasks/
    - log/
      - development.log
      - test.log
    - public/
      - 400.html
      - 404.html
      - 406-unsupported-browser.html
      - 422.html
      - 500.html
      - icon.png
      - icon.svg
      - robots.txt
    - Rails
    - Rakefile
    - Run
    - script/
    - spec/
      - rails_helper.rb
      - requests/
        - api/
          - v1/
            - checkout_create_order_spec.rb
      - spec_helper.rb
    - storage/
    - test/
      - application_system_test_case.rb
      - controllers/
      - fixtures/
        - files/
        - orders.yml
      - helpers/
      - integration/
      - mailers/
      - models/
        - order_test.rb
      - system/
      - test_helper.rb
    - tmp/
      - cache/
        - bootsnap/
          - compile-cache-iseq/...
          - compile-cache-yaml/...
          - load-path-cache
      - pids/
        - server.pid
      - restart.txt
      - server.log
      - server.pid
      - sockets/
      - storage/
    - vendor/
      - javascript/
  - README.md
  - spec/
    - spec_helper.rb
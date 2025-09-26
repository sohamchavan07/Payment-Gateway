class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :full_name
      t.integer :amount_cents
      t.string :currency
      t.string :status
      t.string :stripe_session_id
      t.string :payment_intent_id
      t.json :line_items
      t.json :metadata

      t.timestamps
    end
  end
end

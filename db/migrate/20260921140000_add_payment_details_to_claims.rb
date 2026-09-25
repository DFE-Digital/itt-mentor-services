class AddPaymentDetailsToClaims < ActiveRecord::Migration[8.0]
  def change
    # Rubocop prefers this way of updating the table but it is not compatible with the strong_migrations gem
    safety_assured do
      change_table :claims, bulk: true do |t|
        t.boolean :paid_to_la
        t.datetime :date_paid
      end
    end
  end
end

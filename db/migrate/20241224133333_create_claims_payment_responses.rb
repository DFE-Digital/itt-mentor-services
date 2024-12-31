class CreateClaimsPaymentResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_responses, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.boolean :processed, default: false

      t.timestamps
    end
  end
end

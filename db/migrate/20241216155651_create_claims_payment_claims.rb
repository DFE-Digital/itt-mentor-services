class CreateClaimsPaymentClaims < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_claims, id: :uuid do |t|
      t.references :payment, null: false, foreign_key: true, type: :uuid
      t.references :claim, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

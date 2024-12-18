class CreateClawbackClaims < ActiveRecord::Migration[7.2]
  def change
    create_table :clawback_claims, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.references :clawback, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

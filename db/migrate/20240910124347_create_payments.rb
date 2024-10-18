class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :sent_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :claim_ids, array: true, default: []

      t.timestamps
    end
  end
end

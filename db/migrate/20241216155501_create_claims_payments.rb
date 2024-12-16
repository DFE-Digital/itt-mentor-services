class CreateClaimsPayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :sent_by, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end
  end
end

class CreateRegions < ActiveRecord::Migration[7.1]
  def change
    create_table :regions, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.monetize :claims_funding_available_per_hour, amount: { null: false, default: 0, currency: { present: false } }

      t.timestamps
    end
  end
end

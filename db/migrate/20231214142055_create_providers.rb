class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers, id: :uuid do |t|
      t.string :provider_code, null: false, index: { unique: true }

      t.timestamps
    end
  end
end

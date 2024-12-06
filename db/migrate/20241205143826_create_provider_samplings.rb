class CreateProviderSamplings < ActiveRecord::Migration[7.2]
  def change
    create_table :provider_samplings, id: :uuid do |t|
      t.references :sampling, null: false, foreign_key: true, type: :uuid
      t.references :provider, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

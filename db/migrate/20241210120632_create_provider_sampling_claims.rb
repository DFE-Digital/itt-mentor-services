class CreateProviderSamplingClaims < ActiveRecord::Migration[7.2]
  def change
    create_table :provider_sampling_claims, id: :uuid do |t|
      t.references :claim, null: false, foreign_key: true, type: :uuid
      t.references :provider_sampling, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end

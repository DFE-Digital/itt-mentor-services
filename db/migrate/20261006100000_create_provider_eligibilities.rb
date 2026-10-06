class CreateProviderEligibilities < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_eligibilities, id: :uuid do |t|
      t.references :provider, type: :uuid, null: false, foreign_key: true
      t.references :academic_year, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :provider_eligibilities, %i[provider_id academic_year_id], unique: true, name: "index_provider_eligibilities_on_provider_and_academic_year"
  end
end

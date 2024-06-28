class AddProviderAttributes < ActiveRecord::Migration[7.1]
  def change
    create_enum :provider_type, %w[scitt lead_school university]

    change_table :providers, bulk: true do |t|
      t.enum :provider_type, enum_type: "provider_type", null: false, default: "scitt"
      t.string :name, null: false, default: ""
      t.string :ukprn
      t.string :urn
      t.string :email
      t.string :telephone
      t.string :website

      # Postal address fields
      t.string :street_address_1
      t.string :street_address_2
      t.string :street_address_3
      t.string :town
      t.string :city
      t.string :county
      t.string :postcode
    end
  end
end

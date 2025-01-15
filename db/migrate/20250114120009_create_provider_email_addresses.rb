class CreateProviderEmailAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :provider_email_addresses, id: :uuid do |t|
      t.string :email_address
      t.references :provider, null: false, foreign_key: true, type: :uuid
      t.timestamps

      t.index %i[email_address provider_id], unique: true, name: "unique_provider_email"
    end
  end
end

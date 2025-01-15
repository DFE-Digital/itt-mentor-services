class MigrateProviderEmailAddresses < ActiveRecord::Migration[7.2]
  def up
    email_attributes = Provider.select(:email_address, :id)
      .map do |provider|
        { provider_id: provider.id, email_address: provider.email_address }
      end
    ProviderEmailAddress.upsert_all(
      email_attributes,
      unique_by: :unique_provider_email,
    )
  end

  def down
    ProviderEmailAddress.destroy_all
  end
end

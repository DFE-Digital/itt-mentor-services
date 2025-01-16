class AddPrimaryToProviderEmailAddresses < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :provider_email_addresses, :primary, :boolean, default: false
    add_index :provider_email_addresses, :primary, algorithm: :concurrently
  end
end

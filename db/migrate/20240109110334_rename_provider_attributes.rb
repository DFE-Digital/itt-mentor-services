class RenameProviderAttributes < ActiveRecord::Migration[7.1]
  def change
    rename_column :providers, :email, :email_address
    rename_column :providers, :provider_code, :code
    rename_column :providers, :street_address_1, :address1
    rename_column :providers, :street_address_2, :address2
    rename_column :providers, :street_address_3, :address3
  end
end

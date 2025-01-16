class RemoveEmailAddressFromProviders < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :providers, :email_address, :string }
  end
end

class AssignPrimaryTrueToExistingProviderEmailAddresses < ActiveRecord::Migration[7.2]
  def up
    ProviderEmailAddress.update_all(primary: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

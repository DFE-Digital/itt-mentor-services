class AddManuallyOnboardedByToSchools < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :schools, :manually_onboarded_by, polymorphic: true, type: :uuid, index: { algorithm: :concurrently }
  end
end

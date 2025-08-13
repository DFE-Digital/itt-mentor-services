class AddClawbackApprovedByToClaims < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :claims, :clawback_approved_by, type: :uuid, index: { algorithm: :concurrently }
  end
end

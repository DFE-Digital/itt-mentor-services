class AddClawbackRequestedByToClaims < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :claims, :clawback_requested_by, type: :uuid, index: { algorithm: :concurrently }
  end
end

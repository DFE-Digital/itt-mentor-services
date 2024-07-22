class AddClaimWindowToClaims < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :claims, :claim_window, type: :uuid, index: { algorithm: :concurrently }
  end
end

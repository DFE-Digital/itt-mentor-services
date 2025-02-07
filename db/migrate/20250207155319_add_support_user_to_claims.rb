class AddSupportUserToClaims < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :claims, :support_user, type: :uuid, index: { algorithm: :concurrently }
  end
end

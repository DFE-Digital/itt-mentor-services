class AddSendToPlacements < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :placements, :send_specific, :boolean, default: false
    add_reference :placements, :key_stage, type: :uuid, index: { algorithm: :concurrently }
  end
end

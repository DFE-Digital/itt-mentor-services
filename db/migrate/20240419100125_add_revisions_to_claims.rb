class AddRevisionsToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :previous_revision_id, :uuid, null: true
    add_index :claims, :previous_revision_id
  end
end

class RemovePreviousRevisionIdFromClaim < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :claims, :previous_revision_id, type: :uuid }
  end
end

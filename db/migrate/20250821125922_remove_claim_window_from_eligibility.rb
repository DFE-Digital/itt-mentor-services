class RemoveClaimWindowFromEligibility < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :eligibilities, :claim_windows

    # The logic has already been implemented to support the removal of the claim_window_id column.
    safety_assured { remove_column :eligibilities, :claim_window_id, type: :uuid }
  end
end

class AddClawbackRequiresApprovalStatusToClaims < ActiveRecord::Migration[8.0]
  def change
    add_enum_value :claim_status, "clawback_requires_approval"
  end
end

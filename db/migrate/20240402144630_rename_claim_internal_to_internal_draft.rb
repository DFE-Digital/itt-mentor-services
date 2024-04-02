class RenameClaimInternalToInternalDraft < ActiveRecord::Migration[7.1]
  def change
    rename_enum_value :claim_status, from: "internal", to: "internal_draft"
  end
end

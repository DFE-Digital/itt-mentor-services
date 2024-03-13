class AddStatusesToClaim < ActiveRecord::Migration[7.1]
  def change
    create_enum :claim_status, %w[internal draft submitted]

    add_column :claims, :status, :enum, enum_type: "claim_status"
  end
end

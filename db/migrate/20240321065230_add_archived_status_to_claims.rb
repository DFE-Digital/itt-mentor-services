class AddArchivedStatusToClaims < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :claim_status, "archived"
  end
end

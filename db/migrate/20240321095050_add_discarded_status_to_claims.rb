class AddDiscardedStatusToClaims < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :claim_status, "discarded"
  end
end

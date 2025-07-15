class AddInvalidProviderStatusToClaim < ActiveRecord::Migration[8.0]
  def change
    add_enum_value :claim_status, "invalid_provider"
  end
end

class AddUnpaidReasonToClaims < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :unpaid_reason, :text
  end
end

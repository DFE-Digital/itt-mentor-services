class AddPaymentInProgressAtToClaims < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :payment_in_progress_at, :datetime
  end
end

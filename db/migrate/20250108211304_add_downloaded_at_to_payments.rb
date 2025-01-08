class AddDownloadedAtToPayments < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :downloaded_at, :datetime
  end
end

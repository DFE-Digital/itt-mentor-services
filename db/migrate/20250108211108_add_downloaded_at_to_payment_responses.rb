class AddDownloadedAtToPaymentResponses < ActiveRecord::Migration[7.2]
  def change
    add_column :payment_responses, :downloaded_at, :datetime
  end
end

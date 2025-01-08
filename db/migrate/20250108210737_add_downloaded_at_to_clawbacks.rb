class AddDownloadedAtToClawbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :clawbacks, :downloaded_at, :datetime
  end
end

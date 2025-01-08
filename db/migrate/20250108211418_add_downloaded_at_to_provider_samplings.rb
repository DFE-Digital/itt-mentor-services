class AddDownloadedAtToProviderSamplings < ActiveRecord::Migration[7.2]
  def change
    add_column :provider_samplings, :downloaded_at, :datetime
  end
end

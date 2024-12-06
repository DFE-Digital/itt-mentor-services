class AddProviderSamplingIdToClaim < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :claims, :provider_sampling, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end

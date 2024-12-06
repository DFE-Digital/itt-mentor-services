class AddProviderSamplingForeignKey < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :claims, :provider_samplings, validate: false
  end
end

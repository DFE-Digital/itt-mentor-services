class ValidateAddProviderSamplingForeignKey < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :claims, :provider_samplings
  end
end

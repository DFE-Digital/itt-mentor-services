class AddTrigramIndexToProviders < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;" }

    add_index :providers, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_providers_on_name_trigram", algorithm: :concurrently
    add_index :providers, :postcode, using: :gin, opclass: :gin_trgm_ops, name: "index_providers_on_postcode_trigram", algorithm: :concurrently
    add_index :providers, :urn, using: :gin, opclass: :gin_trgm_ops, name: "index_providers_on_urn_trigram", algorithm: :concurrently
    add_index :providers, :ukprn, using: :gin, opclass: :gin_trgm_ops, name: "index_providers_on_ukprn_trigram", algorithm: :concurrently
  end

  def down
    remove_index :providers, :name, name: "index_providers_on_name_trigram"
    remove_index :providers, :postcode, name: "index_providers_on_postcode_trigram"
    remove_index :providers, :urn, name: "index_providers_on_urn_trigram"
    remove_index :providers, :ukprn, name: "index_providers_on_ukprn_trigram"
  end
end

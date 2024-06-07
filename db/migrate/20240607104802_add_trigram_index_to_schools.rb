class AddTrigramIndexToSchools < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;" }

    add_index :schools, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_schools_on_name_trigram", algorithm: :concurrently
    add_index :schools, :postcode, using: :gin, opclass: :gin_trgm_ops, name: "index_schools_on_postcode_trigram", algorithm: :concurrently
    add_index :schools, :urn, using: :gin, opclass: :gin_trgm_ops, name: "index_schools_on_urn_trigram", algorithm: :concurrently
  end

  def down
    remove_index :schools, :name, name: "index_schools_on_name_trigram"
    remove_index :schools, :postcode, name: "index_schools_on_postcode_trigram"
    remove_index :schools, :urn, name: "index_schools_on_urn_trigram"
  end
end

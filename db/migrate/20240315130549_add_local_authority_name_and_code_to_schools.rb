class AddLocalAuthorityNameAndCodeToSchools < ActiveRecord::Migration[7.1]
  def change
    change_table :schools, bulk: true do |t|
      t.string :local_authority_name
      t.string :local_authority_code
    end
  end
end

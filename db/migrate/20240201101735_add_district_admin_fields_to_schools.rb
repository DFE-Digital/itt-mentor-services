class AddDistrictAdminFieldsToSchools < ActiveRecord::Migration[7.1]
  def change
    change_table :schools, bulk: true do |t|
      t.string :district_admin_name
      t.string :district_admin_code
    end
  end
end

class AddVendorNumberToSchool < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :vendor_number, :string
  end
end

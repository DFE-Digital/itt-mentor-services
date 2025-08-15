class RemoveEmailAddressFromSchools < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :schools, :email_address, :string }
  end
end

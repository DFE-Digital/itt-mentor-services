class RemoveEmailAddressFromSchools < ActiveRecord::Migration[8.0]
  def change
    # This column must be ignored in the School model before deploying this migration
    # class School < ApplicationRecord
    #   self.ignored_columns += ["email_address"]
    # end

    safety_assured { remove_column :schools, :email_address, :string }
  end
end

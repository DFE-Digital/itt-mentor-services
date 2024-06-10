class AddFirstNameAndLastNameToSchoolContact < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :school_contacts, bulk: true do |t|
        t.string :first_name
        t.string :last_name
      end
    end
  end
end

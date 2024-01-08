class AddGiasSchoolFieldsToSchool < ActiveRecord::Migration[7.1]
  def change
    change_table :schools, bulk: true do |t|
      t.string :name
      t.string :postcode
      t.string :town
      t.string :ukprn
      t.string :telephone
      t.string :website
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :group
      t.string :type_of_establishment
      t.string :phase
      t.string :gender
      t.integer :minimum_age
      t.integer :maximum_age
      t.string :religious_character
      t.string :admissions_policy
      t.string :urban_or_rural
      t.integer :school_capacity
      t.integer :total_pupils
      t.integer :total_girls
      t.integer :total_boys
      t.integer :percentage_free_school_meals
      t.string :special_classes
      t.string :send_provision
      t.string :training_with_disabilities
      t.string :rating
      t.date :last_inspection_date
      t.string :email_address
    end
  end
end

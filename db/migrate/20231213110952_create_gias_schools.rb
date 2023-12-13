class CreateGiasSchools < ActiveRecord::Migration[7.1]
  def change
    create_table :gias_schools, id: :uuid do |t|
      t.string :urn, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :postcode
      t.string :town
      t.string :ukprn
      t.string :telephone
      t.string :website
      t.string :address1
      t.string :address2
      t.string :address3

      t.timestamps
    end
  end
end

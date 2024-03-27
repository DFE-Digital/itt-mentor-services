class CreateApplicants < ActiveRecord::Migration[7.1]
  def change
    create_table :applicants, id: :uuid do |t|
      t.string :apply_id
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :postcode
      t.float :longitude, index: true
      t.float :latitude, index: true
      t.references :provider, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :applicants, :apply_id, unique: true
  end
end

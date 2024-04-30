class CreateSchoolContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :school_contacts, id: :uuid do |t|
      t.string :name
      t.string :email_address
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end

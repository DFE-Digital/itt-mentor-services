class CreateMentors < ActiveRecord::Migration[7.1]
  def change
    create_table :mentors, id: :uuid do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :trn, null: false

      t.timestamps
    end
  end
end

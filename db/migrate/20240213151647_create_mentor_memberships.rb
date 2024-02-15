class CreateMentorMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :mentor_memberships, id: :uuid do |t|
      t.string :type, null: false
      t.references :mentor, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.index %i[type school_id mentor_id], unique: true
      t.index %i[type mentor_id]

      t.timestamps
    end
  end
end

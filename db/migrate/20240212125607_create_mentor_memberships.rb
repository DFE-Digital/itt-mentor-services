class CreateMentorMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :mentor_memberships, id: :uuid do |t|
      t.string :type
      t.references :mentor, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

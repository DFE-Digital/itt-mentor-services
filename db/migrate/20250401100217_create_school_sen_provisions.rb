class CreateSchoolSENProvisions < ActiveRecord::Migration[7.2]
  def change
    create_table :school_sen_provisions, id: :uuid do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :sen_provision, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end

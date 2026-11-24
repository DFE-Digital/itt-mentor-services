class CreateGrantConditionsAcceptances < ActiveRecord::Migration[8.0]
  def change
    create_table :grant_conditions_acceptances, id: :uuid do |t|
      t.references :school, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :academic_year, type: :uuid, null: false, foreign_key: true
      t.references :accepted_by, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.datetime :accepted_at, null: false

      t.timestamps
    end

    add_index :grant_conditions_acceptances, %i[school_id academic_year_id], unique: true, name: "index_grant_conditions_acceptances_on_school_and_academic_year"
  end
end

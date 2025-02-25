class CreateHostingInterests < ActiveRecord::Migration[7.2]
  create_enum :appetite, %w[actively_looking interested not_open already_organised]

  def change
    create_table :hosting_interests, id: :uuid do |t|
      t.references :academic_year, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.enum :appetite, enum_type: "appetite"
      t.jsonb :reasons_not_hosting
      t.index %i[school_id academic_year_id], unique: true
      t.timestamps
    end
  end
end

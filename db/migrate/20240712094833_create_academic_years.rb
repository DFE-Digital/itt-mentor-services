class CreateAcademicYears < ActiveRecord::Migration[7.1]
  def change
    create_table :academic_years, id: :uuid do |t|
      t.string :name
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end
end

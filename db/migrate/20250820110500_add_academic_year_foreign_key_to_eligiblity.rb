class AddAcademicYearForeignKeyToEligiblity < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :eligibilities, :academic_years, validate: false
  end
end

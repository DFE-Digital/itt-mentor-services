# frozen_string_literal: true

class BackfillPlacementsAcademicYear < ActiveRecord::Migration[7.1]
  def up
    Placement.update_all(academic_year: )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

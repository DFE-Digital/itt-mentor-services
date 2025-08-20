class PopulateAcademicYearForEligibilties < ActiveRecord::Migration[8.0]
  def up
    Claims::Eligibility.find_each do |eligibility|
      academic_year = eligibility.claim_window.academic_year
      eligibility.update!(academic_year:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

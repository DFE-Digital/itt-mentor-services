class BackfillCurrentYearProviderEligibilities < ActiveRecord::Migration[8.0]
  def up
    academic_year = AcademicYear.current

    Provider.accredited.find_each do |provider|
      Claims::ProviderEligibility.find_or_create_by!(provider:, academic_year:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

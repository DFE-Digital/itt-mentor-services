class BackfillCurrentYearProviderEligibilities < ActiveRecord::Migration[8.0]
  def up
    academic_year_id = AcademicYear.current.id

    Provider.accredited.in_batches do |providers|
      Claims::ProviderEligibility.insert_all(
        providers.pluck(:id).map { |provider_id| { provider_id:, academic_year_id: } },
        unique_by: :index_provider_eligibilities_on_provider_and_academic_year,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

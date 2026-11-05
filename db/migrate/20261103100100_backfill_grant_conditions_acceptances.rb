class BackfillGrantConditionsAcceptances < ActiveRecord::Migration[8.0]
  def up
    School.where.not(claims_grant_conditions_accepted_at: nil)
      .where.not(claims_grant_conditions_accepted_by_id: nil)
      .find_each do |school|
        Claims::GrantConditionsAcceptance.insert_all(
          [{
            school_id: school.id,
            academic_year_id: AcademicYear.for_date(school.claims_grant_conditions_accepted_at.to_date).id,
            accepted_by_id: school.claims_grant_conditions_accepted_by_id,
            accepted_at: school.claims_grant_conditions_accepted_at,
          }],
          unique_by: :index_grant_conditions_acceptances_on_school_and_academic_year,
        )
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

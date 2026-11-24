class BackfillGrantConditionsAcceptances < ActiveRecord::Migration[8.0]
  def up
    School.where.not(claims_grant_conditions_accepted_at: nil)
      .where.not(claims_grant_conditions_accepted_by_id: nil)
      .find_each do |school|
        Claims::GrantConditionsAcceptance.insert_all(
          [{
            school_id: school.id,
            academic_year_id: academic_year_id_at(school.claims_grant_conditions_accepted_at.to_date),
            accepted_by_id: school.claims_grant_conditions_accepted_by_id,
            accepted_at: school.claims_grant_conditions_accepted_at,
          }],
          unique_by: :index_grant_conditions_acceptances_on_school_and_academic_year,
        )
      end
  end

  # Matches AcademicYear.for_latest_claim_window as it would have been on the
  # date the grant conditions were accepted.
  def academic_year_id_at(date)
    Claims::ClaimWindow.where(starts_on: ..date).order(starts_on: :desc).pick(:academic_year_id) ||
      AcademicYear.for_date(date).id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

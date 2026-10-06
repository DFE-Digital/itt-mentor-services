# Providers could previously be selected for claims when they were flagged as accredited.
# Make every provider that is currently accredited eligible for the current academic year,
# so that switching to eligibilities does not change who can be selected today.
class BackfillCurrentYearProviderEligibilities < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO provider_eligibilities (id, provider_id, academic_year_id, created_at, updated_at)
        SELECT gen_random_uuid(), providers.id, academic_years.id, NOW(), NOW()
        FROM providers
        CROSS JOIN academic_years
        WHERE providers.accredited = TRUE
          AND CURRENT_DATE BETWEEN academic_years.starts_on AND academic_years.ends_on
        ON CONFLICT (provider_id, academic_year_id) DO NOTHING
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

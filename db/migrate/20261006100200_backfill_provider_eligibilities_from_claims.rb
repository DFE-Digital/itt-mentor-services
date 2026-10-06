# We have no record of which providers were eligible in previous academic years, so a provider
# is made eligible for every academic year in which a claim has been assigned to it.
# Claims flagged as having an invalid provider are ignored, as that status means the provider
# was no longer eligible to be claimed against.
class BackfillProviderEligibilitiesFromClaims < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO provider_eligibilities (id, provider_id, academic_year_id, created_at, updated_at)
        SELECT gen_random_uuid(), claim_providers.provider_id, claim_providers.academic_year_id, NOW(), NOW()
        FROM (
          SELECT DISTINCT claims.provider_id, claim_windows.academic_year_id
          FROM claims
          INNER JOIN claim_windows ON claim_windows.id = claims.claim_window_id
          WHERE claims.provider_id IS NOT NULL
            AND claims.status <> 'invalid_provider'
        ) AS claim_providers
        ON CONFLICT (provider_id, academic_year_id) DO NOTHING
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

class BackfillProviderEligibilitiesFromClaims < ActiveRecord::Migration[8.0]
  def up
    Claims::ClaimWindow.unscoped.find_each do |claim_window|
      provider_ids = Claims::Claim
        .where(claim_window:)
        .where.not(status: :invalid_provider)
        .where.not(provider_id: nil)
        .distinct
        .pluck(:provider_id)

      Claims::ProviderEligibility.insert_all(
        provider_ids.map { |provider_id| { provider_id:, academic_year_id: claim_window.academic_year_id } },
        unique_by: :index_provider_eligibilities_on_provider_and_academic_year,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

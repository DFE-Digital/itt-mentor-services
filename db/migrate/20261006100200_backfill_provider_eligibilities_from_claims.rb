class BackfillProviderEligibilitiesFromClaims < ActiveRecord::Migration[8.0]
  def up
    academic_year_ids = Claims::ClaimWindow.unscoped.pluck(:id, :academic_year_id).to_h

    Claims::Claim
      .where.not(status: :invalid_provider)
      .where.not(provider_id: nil)
      .distinct
      .pluck(:provider_id, :claim_window_id)
      .map { |provider_id, claim_window_id| [provider_id, academic_year_ids[claim_window_id]] }
      .uniq
      .each do |provider_id, academic_year_id|
        next if academic_year_id.nil?

        Claims::ProviderEligibility.find_or_create_by!(provider_id:, academic_year_id:)
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

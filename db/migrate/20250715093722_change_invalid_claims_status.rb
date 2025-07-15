class ChangeInvalidClaimsStatus < ActiveRecord::Migration[8.0]
  def up
    accredited_providers = Claims::Provider.accredited
    invalid_claims = Claims::Claim.where.not(provider: accredited_providers)

    # We want this to be reflected in Big Query, so we're using callbacks despite the performance hit
    invalid_claims.find_each { |claim| claim.update!(status: :invalid_provider) }

    Claims::Claim::InvalidProviderNotification.call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

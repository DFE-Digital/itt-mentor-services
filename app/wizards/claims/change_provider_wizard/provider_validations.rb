module Claims::ChangeProviderWizard::ProviderValidations
  extend ActiveSupport::Concern

  included do
    validate :provider_is_different
    validate :provider_has_claimable_hours

    delegate :claim, to: :wizard
  end

  private

  def provider_is_different
    errors.add(:id, :same_provider) if provider.present? && provider == claim.provider
  end

  def provider_has_claimable_hours
    return if provider.blank? || claim.mentor_trainings.empty?
    return if wizard.claimable_hours_for(provider).values.any?(&:positive?)

    errors.add(:id, :no_claimable_hours, provider_name: provider.name)
  end
end

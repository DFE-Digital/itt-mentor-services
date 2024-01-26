class ProviderOnboardingForm < ApplicationForm
  attr_accessor :id, :javascript_disabled

  validate :id_presence
  validate :provider_already_onboarded?

  def onboard
    return false unless valid?

    provider.update!(placements_service: true)
  end

  def provider
    @provider ||= Provider.find(id)
  rescue ActiveRecord::RecordNotFound
    errors.add(:id, :blank)
    nil
  end

  private

  def provider_already_onboarded?
    if provider&.placements_service?
      errors.add(:id, :already_added, provider_name: provider.name)
    end
  end

  def id_presence
    errors.add(:id, id_error_message) if id.blank?
  end

  def id_error_message
    if javascript_disabled
      :option_blank
    else
      :blank
    end
  end
end

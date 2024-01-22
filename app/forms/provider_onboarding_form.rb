class ProviderOnboardingForm < ApplicationForm
  attr_accessor :code, :javascript_disabled

  validate :code_presence
  validate :provider_exists?
  validate :provider_already_onboarded?

  def onboard
    return false unless valid?

    provider.update!(placements: true)
  end

  def provider
    @provider ||= Provider.find_by(code:)
  end

  private

  def provider_exists?
    errors.add(:code, :blank) if provider.blank?
  end

  def provider_already_onboarded?
    if provider&.placements?
      errors.add(:code, :already_added, provider_name: provider.name)
    end
  end

  def code_presence
    errors.add(:code, code_error_message) if code.blank?
  end

  def code_error_message
    if javascript_disabled
      :option_blank
    else
      :blank
    end
  end
end

class ProviderOnboardingForm
  include ActiveModel::Model

  attr_accessor :code, :javascript_disabled

  validates :code, presence: true
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
    errors.add(:code, urn_error_message) if provider.blank?
  end

  def provider_already_onboarded?
    if provider&.placements?
      errors.add(:code, :already_added, provider_name: provider.name)
    end
  end

  def urn_error_message
    if javascript_disabled == true
      :option_blank
    else
      :blank
    end
  end
end

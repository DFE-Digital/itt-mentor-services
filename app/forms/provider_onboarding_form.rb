class ProviderOnboardingForm < ApplicationForm
  attr_accessor :id, :javascript_disabled

  validate :id_presence
  validate :provider_exists?
  validate :provider_already_onboarded?

  delegate :id, :name, to: :provider, allow_nil: true, prefix: true

  def persist
    provider.update!(placements_service: true)
  end

  def provider
    @provider ||= Provider.find_by(id:)
  end

  def as_form_params
    { "provider" => { id:, javascript_disabled: } }
  end

  private

  def provider_exists?
    errors.add(:id, :blank) if provider.blank?
  end

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

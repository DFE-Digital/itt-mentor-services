class Placements::PartnershipForm < ApplicationForm
  attr_accessor :school_id, :provider_id, :javascript_disabled, :form_input

  validate :id_presence
  validate :validate_provider
  validate :validate_school
  validate :partnership_already_exists?

  def provider
    @provider ||= ::Provider.find_by(id: provider_id)
  end

  def school
    @school ||= ::School.find_by(id: school_id)
  end

  def as_form_params
    { "partnership" => { school_id: school.id, provider_id: provider.id } }
  end

  def persist
    Placements::Partnership.create!(school:, provider:)
  end

  private

  def validate_provider
    errors.add(:provider_id, :blank) if provider.blank?
  end

  def validate_school
    errors.add(:school_id, :blank) if school.blank?
  end

  def partnership_already_exists?
    return if Placements::Partnership.find_by(school:, provider:).blank?

    errors.add(form_input, :already_added, school_name: school.name, provider_name: provider.name)
  end

  def id_presence
    if form_input == :school_id && school_id.blank?
      errors.add(:school_id, id_error_message)
    elsif provider_id.blank?
      errors.add(:provider_id, id_error_message)
    end
  end

  def id_error_message
    if javascript_disabled
      :option_blank
    else
      :blank
    end
  end
end

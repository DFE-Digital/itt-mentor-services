class SchoolOnboardingForm
  include ActiveModel::Model

  attr_accessor :urn, :service, :javascript_disabled

  validate :urn_presence
  validates :service, presence: true, inclusion: { in: %i[placements claims] }
  validate :school_exists?
  validate :school_already_onboarded?

  def onboard
    return false unless valid?

    school.update!(service => true)
  end

  def school
    @school ||= School.find_by(urn:)
  end

  private

  def school_exists?
    errors.add(:urn, :blank) if school.blank?
  end

  def school_already_onboarded?
    if school&.try(service.to_s)
      errors.add(:urn, :already_added, school_name: school.name)
    end
  end

  def urn_presence
    errors.add(:urn, urn_error_message) if urn.blank?
  end

  def urn_error_message
    if javascript_disabled == true
      :option_blank
    else
      :blank
    end
  end
end

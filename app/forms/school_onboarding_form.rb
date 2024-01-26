class SchoolOnboardingForm < ApplicationForm
  attr_accessor :id, :service, :javascript_disabled

  validate :id_presence
  validates :service, presence: true, inclusion: { in: %i[placements claims] }
  validate :school_already_onboarded?

  def onboard
    return false unless valid?

    school.update!("#{service}_service" => true)
  end

  def school
    @school ||= School.find(id)
  rescue ActiveRecord::RecordNotFound
    errors.add(:id, :blank)
    nil
  end

  private

  def school_already_onboarded?
    if school&.try("#{service}_service?")
      errors.add(:id, :already_added, school_name: school.name)
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

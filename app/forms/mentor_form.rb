class MentorForm < ApplicationForm
  FORM_PARAMS = %i[trn].freeze

  attr_accessor :service, :school, :trn, :first_name, :last_name

  validate :validate_mentor
  validate :validate_membership

  def persist
    ActiveRecord::Base.transaction do
      mentor.save! unless mentor.persisted?

      mentor_membership.save!
    end
  end

  def as_form_params
    { "mentor_form" => slice(FORM_PARAMS) }
  end

  def mentor
    @mentor ||= MentorBuilder.call(trn:, first_name:, last_name:).becomes(mentor_klass)
  end

  def validate_mentor
    if mentor.errors.any?
      mentor.errors.each { |err| errors.add(:trn, err.message) }
    end
  end

  private

  def validate_membership
    if mentor_membership.invalid?
      errors.add(:trn, :taken)
    end
  end

  def mentor_membership
    @mentor_membership ||= mentor.mentor_memberships.new(school:)
  end

  def mentor_klass
    { claims: Claims::Mentor,
      placements: Placements::Mentor }.fetch service
  end
end

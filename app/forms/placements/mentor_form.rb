class Placements::MentorForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school
  attribute :trn
  attribute :first_name
  attribute :last_name
  attribute "date_of_birth(1i)", :integer
  attribute "date_of_birth(2i)", :integer
  attribute "date_of_birth(3i)", :integer

  FORM_PARAMS = [:trn, "date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"].freeze

  validate :validate_membership
  validates :date_of_birth, presence: true
  validate :validate_mentor

  def persist
    ActiveRecord::Base.transaction do
      mentor.save! unless mentor.persisted?

      mentor_membership.save!
    end
  end

  def as_form_params
    { "placements_mentor_form" => slice(FORM_PARAMS) }
  end

  def mentor
    @mentor ||= MentorBuilder.call(trn:, date_of_birth:, first_name:, last_name:).becomes(Placements::Mentor)
  end

  def validate_mentor
    if mentor.errors.any?
      mentor.errors.each { |err| errors.add(err.attribute, err.message) }
    end
  end

  def date_of_birth
    Date.new(
      attributes["date_of_birth(1i)"], # year
      attributes["date_of_birth(2i)"], # month
      attributes["date_of_birth(3i)"], # day
    )
  rescue Date::Error, TypeError
    nil
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
end

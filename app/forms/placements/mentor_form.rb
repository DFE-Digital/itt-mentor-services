class Placements::MentorForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school
  attribute :trn
  attribute :first_name
  attribute :last_name
  attribute "date_of_birth(1i)", :integer
  attribute "date_of_birth(2i)", :integer
  attribute "date_of_birth(3i)", :integer
  alias_attribute :year, :"date_of_birth(1i)"
  alias_attribute :month, :"date_of_birth(2i)"
  alias_attribute :day, :"date_of_birth(3i)"

  FORM_PARAMS = [:trn, "date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"].freeze

  validate :validate_membership
  validate :validate_mentor
  validate :validate_date_of_birth
  validates :date_of_birth, presence: true
  validates :date_of_birth, comparison: { less_than: Time.zone.today }

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
    date_args = [year, month, day].map(&:to_i)

    begin
      Date.new(*date_args)
    rescue ArgumentError, RangeError
      Struct.new(:day, :month, :year).new(day, month, year)
    end
  end

  private

  def validate_membership
    if mentor_membership.invalid?
      errors.add(:trn, :taken)
    end
  end

  def validate_date_of_birth
    errors.add(:date_of_birth, :blank) unless date_of_birth.is_a?(Date)
  end

  def mentor_membership
    @mentor_membership ||= mentor.mentor_memberships.new(school:)
  end
end

class Claims::AddMentorWizard::MentorStep < BaseStep
  include ActiveModel::Attributes

  attribute :trn
  attribute "date_of_birth(1i)", :integer
  attribute "date_of_birth(2i)", :integer
  attribute "date_of_birth(3i)", :integer
  alias_attribute :year, :"date_of_birth(1i)"
  alias_attribute :month, :"date_of_birth(2i)"
  alias_attribute :day, :"date_of_birth(3i)"

  validate :validate_membership, if: -> { mentor.present? }
  validate :validate_mentor, if: -> { mentor.present? }
  validate :validate_date_of_birth
  validates :date_of_birth, presence: true
  validates :date_of_birth, comparison: { less_than: Time.zone.today }, if: -> { date_of_birth.is_a?(Date) }

  delegate :school, to: :wizard

  def mentor
    @mentor ||= Claims::MentorBuilder.call(
      trn:,
      date_of_birth:,
    )
  rescue TeachingRecord::RestClient::TeacherNotFoundError
    @mentor ||= nil
  end

  def mentor_membership
    @mentor_membership ||= mentor.mentor_memberships.new(school:)
  end

  def validate_mentor
    if mentor.errors.any?
      mentor.errors.each { |err| errors.add(err.attribute, err.message) }
    end
  end

  def date_of_birth
    @date_of_birth ||= begin
      date_args = [year, month, day].map(&:to_i)

      begin
        Date.new(*date_args)
      rescue ArgumentError, RangeError
        Struct.new(:day, :month, :year).new(day, month, year)
      end
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
end

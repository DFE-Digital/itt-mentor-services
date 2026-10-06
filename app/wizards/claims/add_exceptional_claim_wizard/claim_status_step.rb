class Claims::AddExceptionalClaimWizard::ClaimStatusStep < BaseStep
  SUBMITTED = "submitted".freeze
  PAID = "paid".freeze
  STATUSES = [SUBMITTED, PAID].freeze
  PAID_TO_LA_VALUES = %w[true false].freeze

  attribute :status, :string
  attribute :paid_to_la, :string
  attribute "date_paid(1i)", :integer
  attribute "date_paid(2i)", :integer
  attribute "date_paid(3i)", :integer
  alias_attribute :year, :"date_paid(1i)"
  alias_attribute :month, :"date_paid(2i)"
  alias_attribute :day, :"date_paid(3i)"

  validates :status, inclusion: { in: STATUSES }
  validates :paid_to_la, inclusion: { in: PAID_TO_LA_VALUES }, if: :paid?
  validate :validate_date_paid, if: :paid?

  delegate :claim_window, to: :wizard

  def initialize(wizard:, attributes:)
    super

    return if paid?

    self.paid_to_la = nil
    self.year = nil
    self.month = nil
    self.day = nil
  end

  def paid?
    status == PAID
  end

  def paid_to_la?
    paid_to_la == "true"
  end

  def date_paid
    Date.new(year.to_i, month.to_i, day.to_i)
  rescue ArgumentError, RangeError
    Struct.new(:day, :month, :year).new(day, month, year)
  end

  def date_paid_time
    date = date_paid
    date.in_time_zone if date.is_a?(Date)
  end

  private

  def validate_date_paid
    date = date_paid

    if !date.is_a?(Date)
      errors.add(:date_paid, [year, month, day].all?(&:blank?) ? :blank : :invalid)
    elsif date > Date.current
      errors.add(:date_paid, :future)
    elsif claim_window.present? && date < claim_window.starts_on
      errors.add(:date_paid, :before_claim_window)
    end
  end
end

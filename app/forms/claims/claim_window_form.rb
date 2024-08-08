class Claims::ClaimWindowForm < ApplicationForm
  attr_accessor :id

  date_attribute :starts_on
  date_attribute :ends_on

  attribute :academic_year_id

  validates :starts_on, date_presence: true
  validates :ends_on, date_presence: true
  validates :ends_on, comparison: { greater_than_or_equal_to: :starts_on }, if: -> { starts_on_is_date? && ends_on_is_date? }
  validates :academic_year_id, presence: true

  validate :does_not_start_within_another_claim_window, if: :starts_on_is_date?
  validate :does_not_end_within_another_claim_window, if: :ends_on_is_date?

  def initialize(attributes = {})
    super

    if id
      self.starts_on ||= claim_window.starts_on
      self.ends_on ||= claim_window.ends_on
      self.academic_year_id ||= claim_window.academic_year_id
    end
  end

  def persist
    claim_window.update!(starts_on:, ends_on:, academic_year_id:)
  end

  def new_back_path
    new_claims_support_claim_window_path(claims_claim_window_form: slice(:starts_on, :ends_on, :academic_year_id))
  end

  def edit_back_path
    edit_claims_support_claim_window_path(id, claims_claim_window_form: slice(:starts_on, :ends_on, :academic_year_id))
  end

  def academic_year_name
    AcademicYear.find_by(id: academic_year_id)&.name
  end

  private

  def claim_window
    @claim_window ||= id ? Claims::ClaimWindow.find(id) : Claims::ClaimWindow.new
  end

  def does_not_start_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :starts_on AND ends_on >= :starts_on", starts_on:).exists?

    errors.add(:starts_on, :overlap)
  end

  def does_not_end_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :ends_on AND ends_on >= :ends_on", ends_on:).exists?

    errors.add(:ends_on, :overlap)
  end
end

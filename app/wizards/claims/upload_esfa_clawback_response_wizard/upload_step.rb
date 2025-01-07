class Claims::UploadESFAClawbackResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  # input validation attributes
  attribute :invalid_claim_references, default: []
  attribute :invalid_status_claim_references, default: []
  attribute :missing_mentor_training_claim_references, default: []
  attribute :missing_reason_clawed_back_claim_references, default: []
  attribute :invalid_hours_clawed_back_claim_references, default: []

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }

  delegate :clawback_in_progress_claims, to: :wizard

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def validate_csv_file
    errors.add(:csv_upload, :invalid) unless csv_format
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    assign_csv_content

    self.csv_upload = nil
  end

  def grouped_csv_rows
    @grouped_csv_rows ||= CSV.parse(read_csv, headers: true)
      .group_by { |row| row["claim_reference"] }
  end

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    all_claims_valid_status?
    grouped_csv_rows.each do |claim_reference, esfa_responses|
      next if claim_reference.nil?

      claim = Claims::Claim.find_by(reference: claim_reference)
      if claim.present?
        row_for_each_mentor?(claim, esfa_responses)
        reason_clawed_back_for_each_mentor?(claim_reference, esfa_responses)
        hours_clawed_back_for_each_mentor?(claim, esfa_responses)
      else
        invalid_claim_references << claim_reference
      end
    end

    invalid_claim_references &&
      invalid_status_claim_references.blank? &&
      missing_mentor_training_claim_references.blank? &&
      missing_reason_clawed_back_claim_references.blank? &&
      invalid_hours_clawed_back_claim_references.blank?
  end

  private

  def csv_format
    csv_upload.content_type == "text/csv"
  end

  def assign_csv_content
    self.csv_content = read_csv
  end

  def read_csv
    @read_csv ||= csv_content || csv_upload.read
  end

  def reset_input_attributes
    self.invalid_claim_references = []
    self.invalid_status_claim_references = []
    self.missing_mentor_training_claim_references = []
    self.missing_reason_clawed_back_claim_references = []
    self.invalid_hours_clawed_back_claim_references = []
  end

  ### CSV input valiations

  def all_claims_valid_status?
    claim_references = grouped_csv_rows.keys.compact
    valid_references = clawback_in_progress_claims.where(reference: claim_references).pluck(:reference)
    return true if valid_references.sort == claim_references.sort

    self.invalid_status_claim_references = claim_references - valid_references
  end

  def row_for_each_mentor?(claim, esfa_responses)
    claim_mentor_names = claim.mentors.map(&:full_name)
    esfa_responses_mentor_names = esfa_responses.pluck("mentor_full_name")
    return if claim_mentor_names.sort == esfa_responses_mentor_names.sort

    missing_mentor_training_claim_references << claim.reference
  end

  def reason_clawed_back_for_each_mentor?(claim_reference, esfa_responses)
    reasons_clawed_back = esfa_responses.pluck("reason_clawed_back")
    return unless reasons_clawed_back.any?(&:blank?)

    missing_reason_clawed_back_claim_references << claim_reference
  end

  def hours_clawed_back_for_each_mentor?(claim, esfa_responses)
    hours_clawed_back = esfa_responses.pluck("hours_clawed_back")
    if hours_clawed_back.any?(&:blank?) || invalid_clawback_hours?(claim, esfa_responses)
      invalid_hours_clawed_back_claim_references << claim.reference
    end
  end

  def invalid_clawback_hours?(claim, esfa_responses)
    invalid_hours = false
    mentor_trainings = claim.mentor_trainings.not_assured
    mentor_trainings.each do |mentor_training|
      esfa_response_for_mentor = esfa_responses.find do |esfa_response|
        esfa_response["mentor_full_name"] == mentor_training.mentor_full_name
      end
      next if esfa_response_for_mentor.blank? ||
        esfa_response_for_mentor["hours_clawed_back"].to_i <= mentor_training.hours_completed

      invalid_hours = true
      break
    end
    invalid_hours
  end
end

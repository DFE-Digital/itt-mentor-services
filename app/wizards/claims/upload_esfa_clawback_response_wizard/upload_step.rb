class Claims::UploadESFAClawbackResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  # input validation attributes
  attribute :invalid_claim_references, default: []
  attribute :invalid_status_claim_references, default: []
  attribute :invalid_updated_status_claim_references, default: []

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }

  VALID_UPLOAD_STATUSES = %w[clawback_in_progress clawback_complete].freeze

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

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes
    validate_csv_rows

    invalid_claim_references &&
      invalid_status_claim_references.blank? &&
      invalid_updated_status_claim_references.blank?
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
    self.invalid_updated_status_claim_references = []
  end

  ### CSV input valiations

  def validate_csv_rows
    rows = CSV.parse(read_csv, headers: true).reject { |row| row.all?(&:nil?) }
    validate_claims(rows)
    validate_updated_statuses(rows)
  end

  def validate_claims(rows)
    claim_references = rows.pluck("claim_reference").compact.flatten
    existing_claims = Claims::Claim.where(reference: claim_references)
    existing_claims_references = existing_claims.pluck(:reference)

    invalid_references = claim_references - existing_claims_references
    self.invalid_claim_references = invalid_references if invalid_references.present?

    valid_status_references = clawback_in_progress_claims.where(reference: claim_references).pluck(:reference)
    invalid_status_references = claim_references - valid_status_references
    self.invalid_status_claim_references = invalid_status_references if invalid_status_references.present?
  end

  def validate_updated_statuses(rows)
    invalid_rows = rows.reject do |row|
      VALID_UPLOAD_STATUSES.include?(row["claim_status"]) ||
        row["claim_reference"].blank?
    end
    return if invalid_rows.blank?

    self.invalid_updated_status_claim_references = invalid_rows.pluck("claim_reference")
  end
end

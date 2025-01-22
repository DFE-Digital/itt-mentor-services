class Claims::UploadProviderResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  # input validation attributes
  attribute :invalid_claim_rows, default: []
  attribute :missing_mentor_training_claim_references, default: []
  attribute :invalid_mentor_full_name_rows, default: []
  attribute :invalid_claim_accepted_rows, default: []
  attribute :missing_rejection_reason_rows, default: []

  delegate :sampled_claims, to: :wizard

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :validate_csv_headers, if: -> { csv_content.present? }

  REQUIRED_HEADERS = %w[claim_reference mentor_full_name claim_accepted rejection_reason].freeze
  NOT_ASSURED_STATUSES = %w[false no].freeze
  VALID_ASSURED_STATUS = %w[true false yes no].freeze

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    csv.each_with_index do |row, i|
      validate_claim_reference(row, i)

      validate_mentor(row, i) unless invalid_claim_rows.include?(i)
      validate_claim_accepted(row, i)
      validate_rejection_reason(row, i)
    end

    grouped_csv_rows.each do |claim_reference, provider_responses|
      claim = sampled_claims.find_by(reference: claim_reference)
      next if claim.blank?

      row_for_each_mentor?(claim, provider_responses)
    end

    invalid_claim_rows.blank? &&
      missing_mentor_training_claim_references.blank? &&
      invalid_mentor_full_name_rows.blank? &&
      invalid_claim_accepted_rows.blank? &&
      missing_rejection_reason_rows.blank?
  end

  def validate_csv_file
    errors.add(:csv_upload, :invalid) unless csv_format
  end

  def validate_csv_headers
    csv_headers = CSV.parse(read_csv, headers: true).headers
    missing_columns = REQUIRED_HEADERS - csv_headers
    return if missing_columns.empty?

    errors.add(:csv_upload,
               :invalid_headers,
               missing_columns: missing_columns.map { |string|
                 "‘#{string}’"
               }.to_sentence)
    errors.add(:csv_upload,
               :uploaded_headers,
               uploaded_headers: csv_headers.map { |string|
                 "‘#{string}’"
               }.to_sentence)
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    assign_csv_content
    self.file_name = csv_upload.original_filename

    self.csv_upload = nil
  end

  def grouped_csv_rows
    @grouped_csv_rows ||= csv
      .group_by { |row| row["claim_reference"] }
  end

  def csv
    @csv ||= CSV.parse(read_csv, headers: true, skip_blanks: true)
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
    self.invalid_claim_rows = []
    self.missing_mentor_training_claim_references = []
    self.invalid_mentor_full_name_rows = []
    self.invalid_claim_accepted_rows = []
    self.missing_rejection_reason_rows = []
  end

  ### CSV input valiations

  def validate_claim_reference(row, row_number)
    return if sampled_claims.find_by(reference: row["claim_reference"]).present?

    invalid_claim_rows << row_number
  end

  def validate_mentor(row, row_number)
    claim = sampled_claims.find_by(reference: row["claim_reference"])
    return if claim.mentors.map(&:full_name).include?(row["mentor_full_name"])

    invalid_mentor_full_name_rows << row_number
  end

  def validate_claim_accepted(row, row_number)
    return if VALID_ASSURED_STATUS.include?(row["claim_accepted"])

    invalid_claim_accepted_rows << row_number
  end

  def validate_rejection_reason(row, row_number)
    return unless NOT_ASSURED_STATUSES.include?(row["claim_accepted"]) && row["rejection_reason"].blank?

    missing_rejection_reason_rows << row_number
  end

  def row_for_each_mentor?(claim, provider_responses)
    claim_mentor_names = claim.mentors.map(&:full_name)
    provider_responses_mentor_names = provider_responses.pluck("mentor_full_name")
    return if claim_mentor_names.sort == provider_responses_mentor_names.sort

    missing_mentor_training_claim_references << claim.reference
  end
end

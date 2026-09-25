class Claims::UploadPayerPaymentResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  # input validation attributes
  attribute :invalid_claim_rows, default: []
  attribute :invalid_claim_status_rows, default: []
  attribute :invalid_claim_unpaid_reason_rows, default: []

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :validate_csv_headers, if: -> { csv_content.present? }

  VALID_UPLOAD_STATUSES = %w[submitted paid unpaid].freeze
  REQUIRED_HEADERS = %w[claim_reference claim_status claim_unpaid_reason].freeze

  delegate :payment_in_progress_claims, to: :wizard

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
    self.file_name = csv_upload.original_filename

    self.csv_upload = nil
  end

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes
    csv.each_with_index do |row, i|
      next if row["claim_reference"].blank?

      validate_claim_reference(row, i)
      validate_claim_status(row, i)
      validate_claim_unpaid_reason(row, i)
    end

    invalid_claim_rows.blank? &&
      invalid_claim_status_rows.blank? &&
      invalid_claim_unpaid_reason_rows.blank?
  end

  def validate_csv_headers
    csv_headers = csv.headers
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

  def csv
    @csv ||= CSV.parse(read_csv, headers: true, skip_blanks: true, encoding: "iso-8859-1:utf-8")
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
    self.invalid_claim_status_rows = []
    self.invalid_claim_unpaid_reason_rows = []
  end

  ### CSV input valiations

  def validate_claim_reference(row, row_number)
    return if payment_in_progress_claims.find_by(reference: row["claim_reference"]).present?

    invalid_claim_rows << row_number
  end

  def validate_claim_status(row, row_number)
    return if VALID_UPLOAD_STATUSES.include?(row["claim_status"])

    invalid_claim_status_rows << row_number
  end

  def validate_claim_unpaid_reason(row, row_number)
    return unless row["claim_status"].to_s.downcase == "unpaid" &&
      row["claim_unpaid_reason"].blank?

    invalid_claim_unpaid_reason_rows << row_number
  end
end

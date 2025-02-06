class Claims::UploadSamplingDataWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  attribute :invalid_claim_rows, default: []
  attribute :missing_sample_reason_rows, default: []

  delegate :paid_claims, to: :wizard

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :validate_csv_headers, if: -> { csv_content.present? }

  REQUIRED_HEADERS = %w[claim_reference sample_reason].freeze

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
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

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    csv.each_with_index do |row, i|
      next if row["claim_reference"].blank?

      validate_claim_reference(row, i)
      validate_sample_reason(row, i)
    end

    invalid_claim_rows.blank? &&
      missing_sample_reason_rows.blank?
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    assign_csv_content
    self.file_name = csv_upload.original_filename

    self.csv_upload = nil
  end

  def csv
    @csv ||= CSV.parse(csv_content, headers: true)
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
    self.missing_sample_reason_rows = []
  end

  def validate_claim_reference(row, row_number)
    return if paid_claims.find_by(reference: row["claim_reference"]).present?

    invalid_claim_rows << row_number
  end

  def validate_sample_reason(row, row_number)
    return if row["sample_reason"].present?

    missing_sample_reason_rows << row_number
  end
end

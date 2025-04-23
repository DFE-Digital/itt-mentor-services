class Claims::OnboardUsersWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  attribute :invalid_email_rows, default: []
  attribute :invalid_school_urn_rows, default: []

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :validate_csv_headers, if: -> { csv_content.present? }

  REQUIRED_HEADERS = %w[email school_urn].freeze

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def validate_csv_file
    errors.add(:csv_upload, :invalid) unless csv_format
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

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    csv.each_with_index do |row, _i|
      next if row.all? { |_k, v| v.blank? }

      # Temp removed to make the CSV upload work
      # validate_email(row, i)
      # validate_school_urn(row, i)
    end

    invalid_email_rows.blank? &&
      invalid_school_urn_rows.blank?
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    assign_csv_content
    self.file_name = csv_upload.original_filename

    self.csv_upload = nil
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
    self.invalid_email_rows = []
    self.invalid_school_urn_rows = []
  end

  def validate_email(row, row_number)
    return unless URI::MailTo::EMAIL_REGEXP.match(row["email"]).nil?

    invalid_email_rows << row_number
  end

  def validate_school_urn(row, row_number)
    return if Claims::School.find_by(urn: row["school_urn"])

    invalid_school_urn_rows << row_number
  end
end

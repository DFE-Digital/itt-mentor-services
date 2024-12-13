class Claims::UploadSamplingDataWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :claim_ids, default: []

  delegate :paid_claims, to: :wizard

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }
  validate :csv_contains_valid_claims

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def validate_csv_file
    errors.add(:csv_upload, :invalid) unless csv_format
  end

  def csv_contains_valid_claims
    return unless claim_ids.count.zero? || csv.length != claim_ids.count

    errors.add(:csv_upload, :invalid_data)
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    reset_claim_ids

    CSV.parse(read_csv, headers: true) do |row|
      claim = paid_claims.find_by(reference: row["claim_reference"])
      break if claim.blank?

      claim_ids << claim.id
    end

    assign_csv_content

    self.csv_upload = nil
  end

  private

  def csv
    @csv ||= CSV.parse(csv_content, headers: true)
  end

  def csv_format
    csv_upload.content_type == "text/csv"
  end

  def assign_csv_content
    self.csv_content = read_csv
  end

  def read_csv
    @read_csv ||= csv_upload.read
  end

  def reset_claim_ids
    self.claim_ids = []
  end
end

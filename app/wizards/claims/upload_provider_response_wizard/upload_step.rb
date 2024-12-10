class Claims::UploadProviderResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :claim_update_details, default: []

  delegate :sampled_claims, to: :wizard

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
    return unless claim_update_details.empty? ||
      grouped_csv_rows.keys.compact.count != claim_update_details.count

    errors.add(:csv_upload, :invalid_data)
  end

  def process_csv
    validate_csv_file
    return if errors.present?

    reset_claim_ids

    grouped_csv_rows.each do |claim_reference, provider_responses|
      next if claim_reference.nil?

      claim = sampled_claims.find_by(reference: claim_reference)
      break if claim.blank? || claim.mentor_trainings.count != provider_responses.count

      claim_update_details << process_responses(claim, provider_responses)
    end

    assign_csv_content

    self.csv_upload = nil
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

  def reset_claim_ids
    self.claim_update_details = []
  end

  def grouped_csv_rows
    @grouped_csv_rows ||= CSV.parse(read_csv, headers: true)
      .group_by { |row| row["claim_reference"] }
  end

  def process_responses(claim, provider_responses)
    if provider_responses.pluck("claim_assured").any?("false")
      {
        id: claim.id,
        status: :sampling_provider_not_approved,
        not_assured_reason: provider_responses
          .pluck("claim_not_assured_reason")
          .join(", "),
      }
    else
      {
        id: claim.id,
        status: :paid,
        not_assured_reason: nil,
      }
    end
  end
end

class Claims::UploadProviderResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  # input validation attributes
  attribute :invalid_status_claim_references, default: []
  attribute :missing_mentor_training_claim_references, default: []
  attribute :invalid_assured_status_claim_references, default: []
  attribute :missing_assured_reason_claim_references, defaukt: []

  delegate :sampled_claims, to: :wizard

  validates :csv_upload, presence: true, if: -> { csv_content.blank? }
  validate :validate_csv_file, if: -> { csv_upload.present? }

  NOT_ASSURED_STATUSES = %w[false no].freeze
  VALID_ASSURED_STATUS = %w[true false yes no].freeze

  def initialize(wizard:, attributes:)
    super(wizard:, attributes:)

    process_csv if csv_upload.present?
  end

  def csv_inputs_valid?
    return true if csv_content.blank?

    reset_input_attributes

    all_claims_valid_status?
    grouped_csv_rows.each do |claim_reference, provider_responses|
      next if claim_reference.nil?

      claim = Claims::Claim.find_by(reference: claim_reference)
      row_for_each_mentor?(claim, provider_responses)
      assured_status_for_each_mentor?(claim_reference, provider_responses)
      not_assured_reason_for_each_mentor?(claim_reference, provider_responses)
    end

    invalid_status_claim_references.blank? &&
      missing_mentor_training_claim_references.blank? &&
      invalid_assured_status_claim_references.blank? &&
      missing_assured_reason_claim_references.blank?
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

  def grouped_csv_rows
    @grouped_csv_rows ||= CSV.parse(read_csv, headers: true)
      .group_by { |row| row["claim_reference"] }
  end

  def reset_input_attributes
    self.invalid_status_claim_references = []
    self.missing_mentor_training_claim_references = []
    self.invalid_assured_status_claim_references = []
    self.missing_assured_reason_claim_references = []
  end

  ### CSV input valiations

  def all_claims_valid_status?
    claim_references = grouped_csv_rows.keys.compact
    valid_references = sampled_claims.where(reference: claim_references).pluck(:reference)
    return true if valid_references.sort == claim_references.sort

    self.invalid_status_claim_references = claim_references - valid_references
  end

  def row_for_each_mentor?(claim, provider_responses)
    claim_mentor_names = claim.mentors.map(&:full_name)
    provider_responses_mentor_names = provider_responses.pluck("mentor_full_name")
    return if claim_mentor_names.sort == provider_responses_mentor_names.sort

    missing_mentor_training_claim_references << claim.reference
  end

  def assured_status_for_each_mentor?(claim_reference, provider_responses)
    assured_statuses = provider_responses.pluck("claim_assured")

    return unless assured_statuses.any? do |assured_status|
      !VALID_ASSURED_STATUS.include?(assured_status.to_s.downcase)
    end

    invalid_assured_status_claim_references << claim_reference
  end

  def not_assured_reason_for_each_mentor?(claim_reference, provider_responses)
    assured_statuses = provider_responses.pluck("claim_assured")
    return nil unless assured_statuses.any? do |assured_status|
      NOT_ASSURED_STATUSES.include?(assured_status.to_s.downcase)
    end

    return if provider_responses.select { |provider_response|
      NOT_ASSURED_STATUSES.include?(provider_response["claim_assured"].to_s.downcase) &&
        provider_response["claim_not_assured_reason"].blank?
    }.blank?

    missing_assured_reason_claim_references << claim_reference
  end
end

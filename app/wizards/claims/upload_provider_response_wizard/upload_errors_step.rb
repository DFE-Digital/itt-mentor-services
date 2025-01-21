class Claims::UploadProviderResponseWizard::UploadErrorsStep < BaseStep
  delegate :invalid_claim_rows,
           :missing_mentor_training_claim_references,
           :invalid_mentor_full_name_rows,
           :invalid_claim_accepted_rows,
           :missing_rejection_reason_rows,
           :file_name,
           to: :upload_step

  def row_indexes_with_errors
    combined_errors.uniq.sort
  end

  def error_count
    combined_errors.count
  end

  def csv
    @csv = CSV.parse(wizard.steps.fetch(:upload).csv_content, headers: true)
  end

  private

  def combined_errors
    invalid_claim_rows +
      invalid_mentor_full_name_rows +
      invalid_claim_accepted_rows +
      missing_rejection_reason_rows
  end

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

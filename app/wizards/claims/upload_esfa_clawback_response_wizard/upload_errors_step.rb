class Claims::UploadESFAClawbackResponseWizard::UploadErrorsStep < BaseStep
  delegate :invalid_claim_rows,
           :invalid_claim_status_rows,
           :file_name,
           :csv,
           to: :upload_step

  def row_indexes_with_errors
    combined_errors.uniq.sort
  end

  def error_count
    combined_errors.count
  end

  private

  def combined_errors
    invalid_claim_rows +
      invalid_claim_status_rows
  end

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

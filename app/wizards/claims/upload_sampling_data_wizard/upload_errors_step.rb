class Claims::UploadSamplingDataWizard::UploadErrorsStep < BaseStep
  delegate :invalid_claim_rows,
           :file_name,
           :csv,
           to: :upload_step

  def row_indexes_with_errors
    invalid_claim_rows.uniq.sort
  end

  def error_count
    invalid_claim_rows.count
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

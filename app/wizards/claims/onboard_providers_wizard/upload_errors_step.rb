class Claims::OnboardProvidersWizard::UploadErrorsStep < BaseStep
  delegate :file_name, :csv, :invalid_email_rows, :invalid_provider_code_rows,
           :missing_first_name_rows, :missing_last_name_rows, to: :upload_step

  def row_indexes_with_errors
    (invalid_email_rows + invalid_provider_code_rows + missing_first_name_rows + missing_last_name_rows).uniq.sort
  end

  def error_count
    row_indexes_with_errors.count
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

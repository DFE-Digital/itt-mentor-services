class Claims::OnboardMultipleSchoolsWizard::UploadErrorsStep < BaseStep
  delegate :invalid_school_name_rows,
           :invalid_school_urn_rows,
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
    invalid_school_name_rows +
      invalid_school_urn_rows
  end

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

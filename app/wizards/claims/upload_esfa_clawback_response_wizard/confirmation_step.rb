class Claims::UploadESFAClawbackResponseWizard::ConfirmationStep < BaseStep
  delegate :file_name, :csv, to: :upload_step

  def csv_headers
    @csv_headers ||= csv.headers
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

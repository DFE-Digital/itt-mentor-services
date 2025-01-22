class Claims::UploadProviderResponseWizard::ConfirmationStep < BaseStep
  delegate :grouped_csv_rows, to: :wizard
  delegate :file_name, :csv, to: :upload_step

  def claims_count
    grouped_csv_rows.keys.compact.count
  end

  def csv_headers
    @csv_headers ||= csv.headers
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

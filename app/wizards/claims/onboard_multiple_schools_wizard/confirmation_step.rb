class Claims::OnboardMultipleSchoolsWizard::ConfirmationStep < BaseStep
  delegate :file_name, :csv, to: :upload_step
  delegate :claim_window, to: :wizard

  def csv_headers
    @csv_headers ||= csv.headers
  end

  def claim_window_name
    "#{I18n.l(claim_window.starts_on, format: :long)} to #{I18n.l(claim_window.ends_on, format: :long)}"
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end

class Claims::UploadProviderResponseWizard::ConfirmationStep < BaseStep
  delegate :grouped_csv_rows, to: :wizard

  def claims_count
    grouped_csv_rows.keys.compact.count
  end
end

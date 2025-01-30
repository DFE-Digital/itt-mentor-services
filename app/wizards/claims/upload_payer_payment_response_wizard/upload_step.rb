class Claims::UploadPayerPaymentResponseWizard::UploadStep < BaseStep
  attribute :csv_upload
  attribute :csv_content
  attribute :file_name
  # input validation attributes
  attribute :invalid_claim_rows, default: []
  attribute :invalid_claim_status_rows, default: []

  def csv_inputs_valid?
    true
  end
end

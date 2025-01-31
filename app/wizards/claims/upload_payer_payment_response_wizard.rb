module Claims
  class UploadPayerPaymentResponseWizard < BaseWizard
    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user

      super(state:, params:, current_step:)
    end

    def define_steps
      if payment_in_progress_claims.present?
        add_step(UploadStep)
        if csv_inputs_valid?
          add_step(ConfirmationStep)
        else
          add_step(UploadErrorsStep)
        end
      else
        add_step(NoClaimsStep)
      end
    end

    def upload_payer_responses
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      csv_file = Claims::PaymentResponse::GenerateCSVFile.call(csv_content: steps.fetch(:upload).csv_content)
      payment_response = Claims::PaymentResponse.create!(csv_file: File.open(csv_file.to_io), user: current_user)

      Claims::Payment::UpdateCollectionWithPayerResponseJob.perform_later(claim_update_details)

      Claims::ClaimActivity.create!(action: :payment_response_uploaded, user: current_user, record: payment_response)
    end

    def payment_in_progress_claims
      Claims::Claim.payment_in_progress
    end

    def claim_update_details
      return [] if steps[:upload].blank?

      csv_rows.map do |row|
        claim = payment_in_progress_claims.find_by!(reference: row["claim_reference"])
        {
          id: claim.id,
          status: row["claim_status"],
          unpaid_reason: row["claim_unpaid_reason"],
        }
      end
    end

    private

    attr_reader :current_user

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def csv_rows
      steps.fetch(:upload).csv.reject do |row|
        row["claim_reference"].blank?
      end
    end
  end
end

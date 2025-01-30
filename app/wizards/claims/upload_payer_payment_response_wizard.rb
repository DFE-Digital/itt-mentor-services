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

    def payment_in_progress_claims
      Claims::Claim.payment_in_progress
    end

    private

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def csv_rows
      csv = steps.fetch(:upload).csv_content
      CSV.parse(csv, headers: true, skip_blanks: true).reject do |row|
        row["claim_reference"].blank?
      end
    end
  end
end

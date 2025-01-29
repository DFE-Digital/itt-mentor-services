module Claims
  class UploadSamplingDataWizard < BaseWizard
    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user

      super(state:, params:, current_step:)
    end

    attr_reader :current_user

    def define_steps
      if paid_claims.present?
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

    def upload_data
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::Sampling::CreateAndDeliverJob.perform_later(current_user_id: current_user.id, claim_ids: uploaded_claim_ids, csv_data:)
    end

    def paid_claims
      Claims::Claim.paid
    end

    def uploaded_claim_ids
      return [] if steps[:upload].blank?

      steps.fetch(:upload).claim_ids
    end

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    private

    def csv_data
      CSV.parse(steps.fetch(:upload).csv_content, headers: true).map(&:to_h)
    end
  end
end

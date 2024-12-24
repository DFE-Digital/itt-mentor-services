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
        add_step(ConfirmationStep)
      else
        add_step(NoClaimsStep)
      end
    end

    def upload_data
      raise "Invalid wizard state" unless valid?

      Claims::Sampling::CreateAndDeliverJob.perform_later(current_user_id: current_user.id, claim_ids: uploaded_claim_ids)
    end

    def paid_claims
      Claims::Claim.paid_for_current_academic_year
    end

    def uploaded_claim_ids
      return [] if steps[:upload].blank?

      steps.fetch(:upload).claim_ids
    end
  end
end

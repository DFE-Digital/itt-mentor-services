module Claims
  class UploadSamplingDataWizard < BaseWizard
    def define_steps
      if paid_claims.present?
        add_step(UploadStep)
        add_step(ConfirmationdStep)
      else
        add_step(NoClaimsStep)
      end
    end

    def uploaded_claim_ids
      return [] if steps[:upload].blank?

      steps.fetch(:upload).claim_ids
    end

    def upload_data
      raise "Invalid wizard state" unless valid?

      Claims::Sampling::FlagCollectionForSamplingJob.perform_later(steps.fetch(:upload).claim_ids)
    end

    def paid_claims
      Claims::Claim.paid_for_current_academic_year
    end
  end
end

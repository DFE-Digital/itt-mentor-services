module Claims
  class UploadProviderResponseWizard < BaseWizard
    def define_steps
      if sampled_claims.present?
        add_step(UploadStep)
        if steps.fetch(:upload).csv_inputs_valid?
          add_step(ConfirmationStep)
        else
          add_step(UploadErrorsStep)
        end
      else
        add_step(NoClaimsStep)
      end
    end

    def upload_provider_responses
      raise "Invalid wizard state" unless valid?

      Claims::Sampling::UpdateCollectionWithProviderResponseJob.perform_later(claim_update_details)
    end

    def sampled_claims
      Claims::Claim.sampling_in_progress
    end

    def claim_update_details
      return [] if steps[:upload].blank?

      steps.fetch(:upload).claim_update_details
    end
  end
end

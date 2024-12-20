module Claims
  class UploadProviderResponseWizard < BaseWizard
    def define_steps
      if sampled_claims.present?
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

    def upload_provider_responses
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::Sampling::UpdateCollectionWithProviderResponseJob.perform_later(claim_update_details)
    end

    def sampled_claims
      @sampled_claims ||= Claims::Claim.sampling_in_progress
    end

    def claim_update_details
      return [] if steps[:upload].blank?

      update_details = []
      grouped_csv_rows.each do |claim_reference, provider_responses|
        next if claim_reference.nil?

        claim = sampled_claims.find_by!(reference: claim_reference)

        all_assured = provider_responses.none? do |provider_response|
          provider_not_assured_mentor_training?(provider_response)
        end
        new_status = all_assured ? :paid : :sampling_provider_not_approved

        update_details << {
          id: claim.id,
          status: new_status,
          provider_responses: provider_responses_for_mentor_trainings(claim, provider_responses),
        }
      end
      update_details
    end

    def grouped_csv_rows
      steps.fetch(:upload).grouped_csv_rows
    end

    private

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def provider_responses_for_mentor_trainings(claim, provider_responses)
      claim.mentor_trainings.map do |mentor_training|
        provider_response_for_mentor = provider_responses.find do |provider_response|
          provider_response["mentor_full_name"] == mentor_training.mentor_full_name
        end

        {
          id: mentor_training.id,
          not_assured: provider_not_assured_mentor_training?(provider_response_for_mentor),
          reason_not_assured: provider_response_for_mentor["claim_not_assured_reason"],
        }
      end
    end

    def not_assured_statuses
      @not_assured_statuses ||= steps.fetch(:upload).class::NOT_ASSURED_STATUSES
    end

    def provider_not_assured_mentor_training?(provider_response)
      not_assured_statuses.include?(provider_response["claim_assured"].to_s.downcase)
    end
  end
end

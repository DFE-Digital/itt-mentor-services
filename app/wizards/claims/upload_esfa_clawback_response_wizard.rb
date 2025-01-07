module Claims
  class UploadESFAClawbackResponseWizard < BaseWizard
    def define_steps
      if clawback_in_progress_claims.present?
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

    def upload_esfa_responses
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::Clawback::UpdateCollectionWithESFAResponseJob.perform_later(claim_update_details)
    end

    def clawback_in_progress_claims
      @clawback_in_progress_claims ||= Claims::Claim.clawback_in_progress
    end

    def grouped_csv_rows
      steps.fetch(:upload).grouped_csv_rows
    end

    def claim_update_details
      return [] if steps[:upload].blank?

      update_details = []
      grouped_csv_rows.each do |claim_reference, esfa_responses|
        next if claim_reference.nil?

        claim = clawback_in_progress_claims.find_by!(reference: claim_reference)

        update_details << {
          id: claim.id,
          status: :clawback_complete,
          esfa_responses: esfa_responses_for_mentor_trainings(claim, esfa_responses),
        }
      end
      update_details
    end

    private

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def esfa_responses_for_mentor_trainings(claim, esfa_responses)
      claim.mentor_trainings.not_assured.map do |mentor_training|
        esfa_response_for_mentor = esfa_responses.find do |esfa_response|
          esfa_response["mentor_full_name"] == mentor_training.mentor_full_name
        end

        {
          id: mentor_training.id,
          reason_clawed_back: esfa_response_for_mentor["reason_clawed_back"],
          hours_clawed_back: esfa_response_for_mentor["hours_clawed_back"],
        }
      end
    end
  end
end

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

        not_assured_statuses = steps.fetch(:upload).class::NOT_ASSURED_STATUSES

        all_assured = provider_responses.none? do |provider_response|
          not_assured_statuses.include?(provider_response["claim_assured"].to_s.downcase)
        end
        new_status = all_assured ? :paid : :sampling_provider_not_approved

        not_assured_reason = if new_status == :sampling_provider_not_approved
                               provider_responses
                                 .pluck("claim_not_assured_reason").join("\n")
                             end

        update_details << {
          id: claim.id,
          status: new_status,
          not_assured_reason:,
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
  end
end

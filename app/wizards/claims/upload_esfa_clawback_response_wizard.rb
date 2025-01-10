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

      Claims::Clawback::UpdateCollectionWithESFAResponseJob.perform_later(updatable_claim_ids)
    end

    def clawback_in_progress_claims
      @clawback_in_progress_claims ||= Claims::Claim.clawback_in_progress
    end

    def claims_count
      csv_rows.count
    end

    private

    def updatable_claim_ids
      return [] if steps[:upload].blank?

      clawback_completable_rows = csv_rows.select { |row| row["claim_status"] == "clawback_complete" }
      references = clawback_completable_rows.pluck("claim_reference")
      Claims::Claim.where(reference: references).ids
    end

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

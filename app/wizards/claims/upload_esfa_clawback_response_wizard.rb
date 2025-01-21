module Claims
  class UploadESFAClawbackResponseWizard < BaseWizard
    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user

      super(state:, params:, current_step:)
    end

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

      csv_file = Claims::ClawbackResponse::GenerateCSVFile.call(csv_content: steps.fetch(:upload).csv_content)
      clawback = Claims::Clawback.create!(claims: Claims::Claim.find(updatable_claim_ids), csv_file: File.open(csv_file.to_io))
      Claims::Clawback::UpdateCollectionWithESFAResponseJob.perform_later(updatable_claim_ids)

      Claims::ClaimActivity.create!(action: :clawback_response_uploaded, user: current_user, record: clawback)
    end

    def clawback_in_progress_claims
      @clawback_in_progress_claims ||= Claims::Claim.clawback_in_progress
    end

    def claims_count
      csv_rows.count
    end

    private

    attr_reader :current_user

    def updatable_claim_ids
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

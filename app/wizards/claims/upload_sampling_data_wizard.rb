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

      Claims::Sampling::CreateAndDeliverJob.perform_later(current_user_id: current_user.id, csv_data: claim_update_details)
    end

    def paid_claims
      Claims::Claim.paid
    end

    def claim_update_details
      return [] if steps[:upload].blank?

      csv_rows.map do |row|
        claim = paid_claims.find_by!(reference: row["claim_reference"])
        {
          id: claim.id,
          sampling_reason: row["sample_reason"],
        }
      end
    end

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    private

    def csv_rows
      steps.fetch(:upload).csv.reject do |row|
        row["claim_reference"].blank?
      end
    end
  end
end

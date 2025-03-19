module Claims
  class OnboardMultipleSchoolsWizard < BaseWizard
    def define_steps
      if claim_windows_exist?
        add_step(ClaimWindowStep)
        add_step(UploadStep)
        if csv_inputs_valid?
          add_step(ConfirmationStep)
        else
          add_step(UploadErrorsStep)
        end
      else
        add_step(NoClaimWindowStep)
      end
    end

    def onboard_schools
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::School::OnboardSchoolsJob.perform_later(
        school_ids:,
        claim_window_id: claim_window.id,
      )
    end

    def claim_window
      @claim_window = Claims::ClaimWindow.find(
        steps.fetch(:claim_window).claim_window_id,
      )
    end

    private

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def school_ids
      @school_ids = ::School.where(urn: csv_rows.pluck("urn")).ids
    end

    def csv_rows
      steps.fetch(:upload).csv.reject do |row|
        row["urn"].blank?
      end
    end

    def claim_windows_exist?
      Claims::ClaimWindow.current.present? ||
        Claims::ClaimWindow.next.present?
    end
  end
end

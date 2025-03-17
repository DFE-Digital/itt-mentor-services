module Claims
  class OnboardMultipleSchoolsWizard < BaseWizard
    def define_steps
      add_step(UploadStep)
      if csv_inputs_valid?
        add_step(ConfirmationStep)
      else
        add_step(UploadErrorsStep)
      end
    end

    def onboard_schools
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::School::OnboardSchoolsJob.perform_later(school_ids:)
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
  end
end

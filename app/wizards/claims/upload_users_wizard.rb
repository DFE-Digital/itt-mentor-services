module Claims
  class UploadUsersWizard < ClaimBaseWizard
    attr_reader :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school

      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(UploadStep)
      if csv_inputs_valid?
        add_step(ConfirmationStep)
      else
        add_step(UploadErrorsStep)
      end
    end

    def upload_users
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      Claims::User::CreateCollectionJob.perform_later(school_id: school.id, user_details:)
    end

    private

    def user_details
      details = []
      steps.fetch(:upload).csv.each do |row|
        details << {
          first_name: row["first_name"],
          last_name: row["last_name"],
          email: row["email"],
        }
      end
      details
    end

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end
  end
end

module Claims
  class UploadUsersWizard < ClaimBaseWizard
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

      Claims::User::CreateCollectionJob.perform_later(user_details:)
    end

    private

    def user_details
      details = []
      csv_rows.each do |row|
        school = Claims::School.find_by!(urn: row["school_urn"])
        details << {
          school_id: school.id,
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

    def csv_rows
      steps.fetch(:upload).csv.reject do |row|
        row["email"].blank? || row["school_urn"].blank?
      end
    end
  end
end

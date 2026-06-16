module Claims
  class OnboardProvidersWizard < ClaimBaseWizard
    def define_steps
      add_step(UploadStep)
      if csv_inputs_valid?
        add_step(ConfirmationStep)
      else
        add_step(UploadErrorsStep)
      end
    end

    def upload_providers
      raise "Invalid wizard state" unless valid? && csv_inputs_valid?

      return if provider_user_details.blank?

      Claims::ProviderUser::CreateCollectionJob.perform_later(provider_user_details:)
    end

    private

    def provider_user_details
      @provider_user_details ||= begin
        details = []
        csv_rows.each do |row|
          provider = Claims::Provider.find_by(code: row["provider_code"])
          next if provider.blank?
          next if row["email"].blank? || URI::MailTo::EMAIL_REGEXP.match(row["email"]).nil?

          details << {
            provider_id: provider.id,
            first_name: row["first_name"],
            last_name: row["last_name"],
            email: row["email"],
          }
        end
        details
      end
    end

    def csv_inputs_valid?
      @csv_inputs_valid ||= steps.fetch(:upload).csv_inputs_valid?
    end

    def csv_rows
      steps.fetch(:upload).csv.reject do |row|
        row["email"].blank? || row["provider_code"].blank?
      end
    end
  end
end

module PublishTeacherTraining
  module Provider
    class Importer < ApplicationService
      def call
        @invalid_records = []
        @records = []
        @email_details = []

        fetch_providers

        if @invalid_records.any?
          Rails.logger.info "Invalid Providers - #{@invalid_records.inspect}"
        end

        Rails.logger.silence do
          ::Provider.upsert_all(@records, unique_by: :code)
          ::ProviderEmailAddress.upsert_all(
            upsert_emails_attributes,
            unique_by: :unique_provider_email,
          )
        end

        Rails.logger.info "Done!"
      end

      private

      def invalid?(provider_attributes)
        provider_attributes["name"].blank? || provider_attributes["provider_type"].blank? ||
          provider_attributes["code"].blank?
      end

      def fetch_providers(link = nil)
        providers = ::PublishTeacherTraining::Provider::Api.call(link:)
        providers.fetch("data").each do |provider_details|
          provider_attributes = provider_details["attributes"]
          @invalid_records << "Provider with code #{provider_attributes["code"]} is invalid" if invalid?(provider_attributes)
          next if invalid?(provider_attributes)

          @records << {
            code: provider_attributes["code"],
            name: provider_attributes["name"],
            provider_type: provider_attributes["provider_type"],
            ukprn: provider_attributes["ukprn"],
            urn: provider_attributes["urn"],
            email_address: provider_attributes["email"], # TODO: Remove once 'email_address' is removed from providers tables
            telephone: provider_attributes["telephone"],
            website: provider_attributes["website"],
            address1: provider_attributes["street_address_1"],
            address2: provider_attributes["street_address_2"],
            address3: provider_attributes["street_address_3"],
            city: provider_attributes["city"],
            county: provider_attributes["county"],
            postcode: provider_attributes["postcode"],
            accredited: provider_attributes["accredited_body"],
          }

          next if provider_attributes["email"].blank?

          @email_details << {
            email_address: provider_attributes["email"],
            code: provider_attributes["code"],
          }
        end

        if providers.dig("links", "next").present?
          fetch_providers(providers.dig("links", "next"))
        end
      end

      def upsert_emails_attributes
        emails_attributes = []
        @email_details.each do |record|
          next if record[:email_address].blank?

          emails_attributes << {
            email_address: record[:email_address],
            provider_id: provider_by_code(record[:code]).id,
          }
        end
        emails_attributes
      end

      def provider_by_code(code)
        ::Provider.find_by(code:)
      end
    end
  end
end

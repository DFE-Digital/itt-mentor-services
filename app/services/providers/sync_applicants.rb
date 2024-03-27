module Providers
  class SyncApplicants
    include ServicePattern

    def initialize
      @applicant_data = Apply::Register::Application::Api.call["data"]
    end

    def call
      sync_applicants
    end

    private

    attr_reader :applicant_data

    def sync_applicants
      applicant_data.each do |applicant_data|
        course_details = applicant_data.dig("attributes", "course")
        provider = Provider.find_by(code: course_details["training_provider_code"])
        next unless provider

        candidate_details = applicant_data.dig("attributes", "candidate")
        contact_details = applicant_data.dig("attributes", "contact_details")

        Applicant.upsert({ apply_id: candidate_details["id"],
                           first_name: candidate_details["first_name"],
                           last_name: candidate_details["last_name"],
                           email_address: contact_details["email"],
                           address1: contact_details["address_line1"],
                           address2: contact_details["address_line2"],
                           address3: contact_details["address_line3"],
                           address4: contact_details["address_line4"],
                           postcode: contact_details["postcode"],
                           provider_id: provider.id }, unique_by: :apply_id)
      end

      nil
    end
  end
end

require "csv"

module Placements
  module Importers
    class ProviderUsersImporter
      include ServicePattern

      attr_reader :csv_path

      def initialize(csv_path)
        @csv_path = csv_path
      end

      def call
        @user_records = Hash.new { |h, k| h[k] = [] }

        CSV.foreach(csv_path, headers: true) do |user|
          @user_records[user["UKPRN"]] << {
            first_name: user["First name"],
            last_name: user["Last name"],
            email: user["Email address"],
          }
        end

        process_user_records

        Rails.logger.info("#{successful_count} of #{total_count} users have been imported successfully.")
      end

      private

      attr_reader :user_records, :successful_count

      def process_user_records
        @successful_count = 0

        user_records.each do |ukprn, users|
          process_provider_users(ukprn, users)
        end
      end

      def process_provider_users(ukprn, users)
        provider = ::Provider.find_by(ukprn:)

        if provider.present?
          onboard_provider(provider)
          process_users(users, provider)
        else
          Rails.logger.error("Failed to import users for provider with UKPRN: #{ukprn}. Provider not found.")
        end
      end

      def onboard_provider(provider)
        provider.update!(placements_service: true)
      end

      def process_users(users, provider)
        users.each do |user|
          process_user(user, provider)
        end
      end

      def process_user(user, provider)
        user_instance = User.find_or_initialize_by(email: user[:email]) do |new_user|
          new_user.first_name = user[:first_name]
          new_user.last_name = user[:last_name]
        end

        user_instance.providers << provider unless user_instance.providers.exists?(provider.id)

        if user_instance.save
          User::Invite.call(user_instance, provider)
          @successful_count += 1
        else
          Rails.logger.error("Failed to import user for #{provider.name}: #{user_instance.errors.full_messages.to_sentence}")
        end
      end

      def total_count
        @total_count ||= user_records.values.sum(&:length)
      end
    end
  end
end

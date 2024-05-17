require "csv"

module Placements
  module Importers
    class SchoolUsersImporter
      include ServicePattern

      attr_reader :csv_path

      def initialize(csv_path)
        @csv_path = csv_path
      end

      def call
        @user_records = Hash.new { |h, k| h[k] = [] }

        CSV.foreach(csv_path, headers: true) do |user|
          @user_records[user["URN"]] << {
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

        user_records.each do |urn, users|
          process_school_users(urn, users)
        end
      end

      def process_school_users(urn, users)
        school = ::School.find_by(urn:)

        if school.present?
          update_school(school)
          process_users(users, school)
        else
          Rails.logger.error("Failed to import users for school with URN: #{urn}. School not found.")
        end
      end

      def update_school(school)
        school.update!(placements_service: true)
      end

      def process_users(users, school)
        users.each do |user|
          process_user(user, school)
        end
      end

      def process_user(user, school)
        user_instance = User.find_or_initialize_by(email: user[:email]) do |new_user|
          new_user.first_name = user[:first_name]
          new_user.last_name = user[:last_name]
          new_user.schools << school unless new_user.schools.exists?(school.id)
        end

        if user_instance.save
          @successful_count += 1
        else
          Rails.logger.error("Failed to import user for #{school.name}: #{user_instance.errors.full_messages.to_sentence}")
        end
      end

      def total_count
        @total_count ||= user_records.values.sum(&:length)
      end
    end
  end
end

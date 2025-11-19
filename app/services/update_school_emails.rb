require "csv"

class UpdateSchoolEmails < ApplicationService
  def initialize(csv_string:)
    @csv_string = csv_string
  end

  def call
    ApplicationRecord.transaction do
      CSV.parse(csv_string, headers: true) do |row|
        school = School.find_by(urn: row["urn"])

        if school.nil?
          Rails.logger.info "School not found with URN: #{row["urn"]} (#{row["name"]})"
          next
        end

        begin
          school.update!(email_address: row["email"])
        rescue ActiveRecord::RecordInvalid
          Rails.logger.info "Invalid email format for: #{row["urn"]} (#{row["name"]})"
          next
        end
      end
    end
  end

  private

  attr_reader :csv_string
end

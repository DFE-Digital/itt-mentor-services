require "csv"

class Claims::ImportSchools
  include ServicePattern

  def initialize(csv_string:)
    @csv_string = csv_string
  end

  def call
    ApplicationRecord.transaction do
      CSV.parse(csv_string, headers: true) do |row|
        school = School.find_by(urn: row["placement_school_urn"])

        begin
          school.update!(claims_service: true)
          user = Claims::User.create!(
            first_name: row["First name"],
            last_name: row["Last name"],
            email: row["Email"],
          )
          school.users << user
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.debug "Error creating user: #{e.message}"
          next
        end
      end
    end
  end

  private

  attr_reader :csv_string
end

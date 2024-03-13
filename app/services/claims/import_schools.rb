require "csv"

class Claims::ImportSchools
  include ServicePattern

  def initialize(csv_file_path:)
    @csv_file_path = csv_file_path
  end

  def call
    urns = CSV.read(csv_file_path, headers: true).map { |row| row["urn"] }

    updated_count = School.where(urn: urns).update_all(claims_service: true)

    Rails.logger.info "#{updated_count} schools updated."
  end

  private

  attr_reader :csv_file_path
end

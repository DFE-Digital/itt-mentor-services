require "csv"

class GiasCsvImporter
  include ServicePattern
  OPEN_SCHOOL = "1".freeze
  NON_ENGLISH_ESTABLISHMENTS = %w[8 10 25 24 26 27 29 30 32 37 49 56 57].freeze

  attr_reader :csv_path, :logger

  def initialize(csv_path)
    @csv_path = csv_path
    @logger = Logger.new($stdout)
  end

  def call
    invalid_records = []
    records = []

    CSV
      .foreach(csv_path, headers: true, encoding: "iso-8859-1:utf-8")
      .with_index(2) do |school, row_number|
        invalid_records << "Row #{row_number} is invalid" if invalid?(school)
        next if school_excluded?(school) || invalid?(school)

        records << {
          urn: school["URN"],
          name: school["EstablishmentName"],
          town: school["Town"].presence,
          postcode: school["Postcode"].presence,
          ukprn: school["UKPRN"].presence,
          address1: school["Street"].presence,
          address2: school["Locality"].presence,
          address3: school["Address3"].presence,
          website: school["SchoolWebsite"].presence,
          telephone: school["TelephoneNum"].presence,
        }
      end

    if invalid_records.any?
      logger.info "Invalid rows - #{invalid_records.inspect}"
    end
    GiasSchool.upsert_all(records, unique_by: :urn)
    logger.info "Done!"
  end

  private

  def invalid?(school)
    school["URN"].blank? || school["EstablishmentName"].blank?
  end

  def school_excluded?(school)
    school["EstablishmentStatus (code)"] != OPEN_SCHOOL ||
      NON_ENGLISH_ESTABLISHMENTS.include?(school["TypeOfEstablishment (code)"])
  end
end

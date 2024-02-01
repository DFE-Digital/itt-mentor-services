require "csv"

class GiasCsvImporter
  include ServicePattern
  OPEN_SCHOOL = "1".freeze
  NON_ENGLISH_ESTABLISHMENTS = %w[8 10 25 24 26 27 29 30 32 37 49 56 57].freeze

  attr_reader :csv_path

  def initialize(csv_path)
    @csv_path = csv_path
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
          district_admin_name: school["DistrictAdministrative (name)"],
          district_admin_code: school["DistrictAdministrative (code)"],
          town: school["Town"].presence,
          postcode: school["Postcode"].presence,
          ukprn: school["UKPRN"].presence,
          address1: school["Street"].presence,
          address2: school["Locality"].presence,
          address3: school["Address3"].presence,
          website: school["SchoolWebsite"].presence,
          telephone: school["TelephoneNum"].presence,
          group: school["EstablishmentTypeGroup (name)"].presence,
          type_of_establishment: school["TypeOfEstablishment (name)"].presence,
          phase: school["PhaseOfEducation (name)"].presence,
          gender: school["Gender (name)"].presence,
          minimum_age: school["StatutoryLowAge"].presence,
          maximum_age: school["StatutoryHighAge"].presence,
          religious_character: school["ReligiousCharacter (name)"].presence,
          admissions_policy: school["AdmissionsPolicy (name)"].presence,
          urban_or_rural: school["UrbanRural (name)"].presence,
          school_capacity: school["SchoolCapacity"].presence,
          total_pupils: school["NumberOfPupils"].presence,
          total_boys: school["NumberOfBoys"].presence,
          total_girls: school["NumberOfGirls"].presence,
          percentage_free_school_meals: school["PercentageFSM"].presence,
          special_classes: school["SpecialClasses (name)"].presence,
          send_provision: school["TypeOfResourcedProvision (name)"].presence,
          rating: school["OfstedRating (name)"].presence,
          last_inspection_date: school["OfstedLastInsp"].presence,
        }
      end

    if invalid_records.any?
      Rails.logger.info "Invalid rows - #{invalid_records.inspect}"
    end
    Rails.logger.silence do
      School.upsert_all(records, unique_by: :urn)
    end

    Rails.logger.info "Done!"
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

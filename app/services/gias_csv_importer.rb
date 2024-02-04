require "csv"

class GiasCsvImporter
  include ServicePattern
  OPEN_SCHOOL = "1".freeze
  NON_ENGLISH_ESTABLISHMENTS = %w[8 10 25 24 26 27 29 30 32 37 49 56 57].freeze
  INNER_LONDON_AREAS = [
    "E09000002", # Barking and Dagenham
    "E09000005", # Brent
    "E09000007", # Camden
    "E09000001", # City of London
    "E09000009", # Ealing
    "E09000011", # Greenwhich
    "E09000012", # Hackney
    "E09000013", # Hammersmith and Fulham
    "E09000014", # Haringey
    "E09000019", # Islington
    "E09000020", # Kensington and Chelsea
    "E09000022", # Lambeth
    "E09000023", # Lewisham
    "E09000024", # Merton
    "E09000025", # Newham
    "E09000028", # Southwark
    "E09000030", # Tower Hamlets
    "E09000032", # Wandsworth
    "E09000033", # Westminster
  ].freeze

  OUTER_LONDON_AREAS = [
    "E09000003", # Barnet
    "E09000004", # Bexley
    "E09000006", # Bromley
    "E09000008", # Croydon
    "E09000010", # Enfield
    "E09000015", # Harrow
    "E09000016", # Havering
    "E09000017", # Hillingdon
    "E09000018", # Hounslow
    "E09000021", # Kingston upon Thames
    "E09000026", # Redbridge
    "E09000027", # Richmond upon Thames
    "E09000029", # Sutton
    "E09000031", # Waltham Forest
  ].freeze

  FRINGE_AREAS = [
    "E06000036", # Bracknell Forest
    "E06000039", # Slough
    "E06000040", # Windsor and Maidenhead
    "E07000006", # South Bucks
    "E07000005", # Chiltern
    "E07000066", # Basildon
    "E07000068", # Brentwood
    "E07000072", # Epping Forest
    "E07000073", # Harlow
    "E06000034", # Thurrock
    "E07000095", # Broxbourne
    "E07000096", # Dacorum
    "E07000242", # East Hertfordshire
    "E07000098", # Hertsmere
    "E07000240", # St Albans
    "E07000102", # Three Rivers
    "E07000103", # Watford
    "E07000241", # Welwyn Hatfield
    "E07000107", # Dartford
    "E07000111", # Sevenoaks
    "E07000226", # Crawley
    # Surrey – the whole county below
    "E07000227", # Reigate and Banstead
    "E07000215", # Tandridge
    "E07000212", # Mole Valley
    "E07000211", # Guildford
    "E07000210", # Epsom and Ewell
    "E07000209", # Elmbridge
    "E07000213", # Spelthorne
    "E07000214", # Surrey Heath
    "E07000216", # Waverley
    "E07000217", # Woking
    "E07000228", # Runnymede
  ].freeze

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
      associate_schools_to_regions
    end

    Rails.logger.info "Done!"
  end

  private

  def associate_schools_to_regions
    Rails.logger.debug "Associating schools to regions... "

    Region.find_or_create_by!(name: "Inner London") { |region| region.claims_funding_available_per_hour = 53.60 }
    Region.find_or_create_by!(name: "Outer London") { |region| region.claims_funding_available_per_hour = 48.25 }
    Region.find_or_create_by!(name: "Fringe") { |region| region.claims_funding_available_per_hour = 45.10 }
    Region.find_or_create_by!(name: "Rest of England") { |region| region.claims_funding_available_per_hour = 43.18 }

    School.find_each do |school|
      region = determine_region(school.district_admin_code)

      unless school.update(region:)
        Rails.logger.info "Failed to update region for school with ID #{school.id}"
      end
    end
  end

  def determine_region(district_admin_code)
    @regions_hash ||= Region.all.index_by(&:name)

    case district_admin_code
    when *INNER_LONDON_AREAS
      @regions_hash["Inner London"]
    when *OUTER_LONDON_AREAS
      @regions_hash["Outer London"]
    when *FRINGE_AREAS
      @regions_hash["Fringe"]
    else
      @regions_hash["Rest of England"]
    end
  end

  def invalid?(school)
    school["URN"].blank? || school["EstablishmentName"].blank?
  end

  def school_excluded?(school)
    school["EstablishmentStatus (code)"] != OPEN_SCHOOL ||
      NON_ENGLISH_ESTABLISHMENTS.include?(school["TypeOfEstablishment (code)"])
  end
end

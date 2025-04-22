require "csv"

module Gias
  class CSVImporter < ApplicationService
    include RegionalAreas

    SUPPORTED_BY_A_TRUST = "1".freeze

    attr_reader :csv_path

    def initialize(csv_path)
      @csv_path = csv_path
    end

    def call
      school_records = []
      trust_records = []
      sen_provision_records = []
      trust_associations = Hash.new { |h, k| h[k] = [] }
      sen_provision_associations = Hash.new { |h, k| h[k] = [] }

      CSV.foreach(csv_path, headers: true) do |school|
        next if school["URN"].blank?

        school_records << {
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
          local_authority_name: school["LA (name)"].presence,
          local_authority_code: school["LA (code)"].presence,
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
          latitude: school["Latitude"].presence,
          longitude: school["Longitude"].presence,
        }

        if school["TrustSchoolFlag (code)"] == SUPPORTED_BY_A_TRUST
          trust_records << {
            uid: school["Trusts (code)"],
            name: school["Trusts (name)"],
          }

          trust_associations[school["Trusts (code)"]] << school["URN"]
        end

        if school["SEN1 (name)"].present?
          sen_provision_records << { name: school["SEN1 (name)"] }
          sen_provision_associations[school["SEN1 (name)"]] << school["URN"]
        end
        if school["SEN2 (name)"].present?
          sen_provision_records << { name: school["SEN2 (name)"] }
          sen_provision_associations[school["SEN2 (name)"]] << school["URN"]
        end
        if school["SEN3 (name)"].present?
          sen_provision_records << { name: school["SEN3 (name)"] }
          sen_provision_associations[school["SEN3 (name)"]] << school["URN"]
        end
        if school["SEN4 (name)"].present?
          sen_provision_records << { name: school["SEN4 (name)"] }
          sen_provision_associations[school["SEN4 (name)"]] << school["URN"]
        end
        if school["SEN5 (name)"].present?
          sen_provision_records << { name: school["SEN5 (name)"] }
          sen_provision_associations[school["SEN5 (name)"]] << school["URN"]
        end
        if school["SEN6 (name)"].present?
          sen_provision_records << { name: school["SEN6 (name)"] }
          sen_provision_associations[school["SEN6 (name)"]] << school["URN"]
        end
        if school["SEN7 (name)"].present?
          sen_provision_records << { name: school["SEN7 (name)"] }
          sen_provision_associations[school["SEN7 (name)"]] << school["URN"]
        end
        if school["SEN8 (name)"].present?
          sen_provision_records << { name: school["SEN8 (name)"] }
          sen_provision_associations[school["SEN8 (name)"]] << school["URN"]
        end
        if school["SEN9 (name)"].present?
          sen_provision_records << { name: school["SEN9 (name)"] }
          sen_provision_associations[school["SEN9 (name)"]] << school["URN"]
        end
        if school["SEN10 (name)"].present?
          sen_provision_records << { name: school["SEN10 (name)"] }
          sen_provision_associations[school["SEN10 (name)"]] << school["URN"]
        end
        if school["SEN11 (name)"].present?
          sen_provision_records << { name: school["SEN11 (name)"] }
          sen_provision_associations[school["SEN11 (name)"]] << school["URN"]
        end
        if school["SEN12 (name)"].present?
          sen_provision_records << { name: school["SEN12 (name)"] }
          sen_provision_associations[school["SEN12 (name)"]] << school["URN"]
        end
        if school["SEN13 (name)"].present?
          sen_provision_records << { name: school["SEN13 (name)"] }
          sen_provision_associations[school["SEN13 (name)"]] << school["URN"]
        end
      end

      Rails.logger.silence do
        School.upsert_all(school_records, unique_by: :urn)
        Trust.upsert_all(trust_records.uniq, unique_by: :uid)
        SENProvision.upsert_all(sen_provision_records.uniq, unique_by: :name)

        associate_schools_to_regions
        associate_schools_to_trusts(trust_associations)
        associate_schools_to_sen_provisions(sen_provision_associations)
      end

      Rails.logger.info "GIAS Data Imported!"
    end

    private

    def associate_schools_to_regions
      Rails.logger.debug "Associating schools to regions... "

      # Inner London Schools
      inner_london = Region.find_or_create_by!(name: "Inner London") { |region| region.claims_funding_available_per_hour = 53.60 }
      School.where(district_admin_code: INNER_LONDON_AREAS).update_all(region_id: inner_london.id)

      # Outer London Schools
      outer_london = Region.find_or_create_by!(name: "Outer London") { |region| region.claims_funding_available_per_hour = 48.25 }
      School.where(district_admin_code: OUTER_LONDON_AREAS).update_all(region_id: outer_london.id)

      # Fringe Schools
      fringe = Region.find_or_create_by!(name: "Fringe") { |region| region.claims_funding_available_per_hour = 45.10 }
      School.where(district_admin_code: FRINGE_AREAS).update_all(region_id: fringe.id)

      # Rest of England Schools
      rest_of_england = Region.find_or_create_by!(name: "Rest of England") { |region| region.claims_funding_available_per_hour = 43.80 }
      School.where(region_id: nil).update_all(region_id: rest_of_england.id)
    end

    def associate_schools_to_trusts(trust_data)
      Rails.logger.debug "Associating schools to trusts... "

      trust_data.each do |uid, urns|
        trust = Trust.find_by!(uid:)
        School.where(urn: urns).update_all(trust_id: trust.id)
      end
    end

    def associate_schools_to_sen_provisions(sen_provision_data)
      Rails.logger.debug "Associating schools to SEN provisions... "

      sen_provision_data.each do |sen_provision_name, urns|
        sen_provision = SENProvision.find_by(name: sen_provision_name)
        sen_provision.schools = School.where(urn: urns)
        sen_provision.save!
      end
    end
  end
end

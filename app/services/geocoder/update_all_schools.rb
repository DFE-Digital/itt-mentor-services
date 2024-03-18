module Geocoder
  class GeocodingError < StandardError; end

  class UpdateAllSchools
    include ServicePattern

    def call
      Rails.logger.info "Begin geocoding schools"

      School.not_geocoded.find_each do |school|
        school.geocode
        school.save!
      rescue StandardError => e
        geocoding_error = GeocodingError.new(
          "Unable to geocode school. School ID: #{school.id}. #{e.message}",
        )
        geocoding_error.set_backtrace(e.backtrace)
        Sentry.capture_exception(geocoding_error)
      end

      Rails.logger.info "Finished geocoding schools"
    end
  end
end

module Geocoder
  class UpdateAllSchools
    include ServicePattern

    def call
      Rails.logger.info "Updating schools with longitude and latitude!"

      School.not_geocoded.find_each do |school|
        school.geocode
        school.save!
      rescue ActiveRecord::RecordInvalid => e
        Sentry.capture_exception(e)
      end

      Rails.logger.info "All schools updated with longitude and latitude!"
    end
  end
end

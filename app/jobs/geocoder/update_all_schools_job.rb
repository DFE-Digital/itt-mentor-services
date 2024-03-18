module Geocoder
  class UpdateAllSchoolsJob < ApplicationJob
    queue_as :default

    def perform
      Geocoder::UpdateAllSchools.call
    end
  end
end

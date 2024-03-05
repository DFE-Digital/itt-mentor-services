module Gias
  class SyncAllSchoolsJob < ApplicationJob
    queue_as :default

    def perform
      tempfile = Gias::CsvDownloader.call
      Rails.logger.info "GIAS CSV Downloaded!"

      Rails.logger.info "Importing GIAS data"
      Gias::CsvImporter.call(tempfile.path)

      tempfile.unlink
    end
  end
end

module Gias
  class SyncAllSchoolsJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info "Downloading GIAS CSV file..."
      gias_csv = Gias::CsvDownloader.call

      Rails.logger.info "Transforming GIAS CSV file..."
      transformed_csv = Gias::CsvTransformer.call(gias_csv)

      Rails.logger.info "Importing GIAS data"
      Gias::CsvImporter.call(transformed_csv.path)

      gias_csv.unlink
      transformed_csv.unlink
      Rails.logger.info "Done"
    end
  end
end

module Gias
  class CsvDownloader
    include ServicePattern

    def call
      today = Time.zone.today.strftime("%Y%m%d")
      gias_filename = "edubasealldata#{today}.csv"

      Rails.logger.info "Downloading the new gias file for #{Time.zone.today}"
      Down.download("#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}")
    end
  end
end

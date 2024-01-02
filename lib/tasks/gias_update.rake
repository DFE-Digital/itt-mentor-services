desc "Upsert GIAS data into GiasSchool"
task gias_update: :environment do
  today = Time.zone.today.strftime("%Y%m%d")
  gias_filename = "edubasealldata#{today}.csv"

  Rails.logger.info "Downloading the new gias file for #{Time.zone.today}"
  tempfile = Down.download("#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}")
  Rails.logger.info "Done!"

  Rails.logger.info "Importing data"
  GiasCsvImporter.call(tempfile.path)

  tempfile.unlink
end

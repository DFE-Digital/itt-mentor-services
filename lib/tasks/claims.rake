namespace :claims do
  desc "Import Schools into the Claims service"
  task import_schools: :environment do
    csv_string = Rails.application.encrypted("lib/data/schools.csv.enc", env_key: "CSV_ENCRYPTION_KEY").read

    Claims::ImportSchools.call(csv_string:)
  end
end

namespace :import_schools do
  desc "Import schools into the claims domain"
  task import: :environment do
    csv_string = Rails.application.encrypted("lib/data/schools.csv.enc").read

    Claims::ImportSchools.call(csv_string:)
  end
end

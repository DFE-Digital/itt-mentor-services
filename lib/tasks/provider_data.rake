namespace :provider_data do
  desc "Import all Providers from Publish Teacher Training"
  task import: :environment do
    AccreditedProvider::Importer.call
  end

  desc "Update and Add to list of Providers updated since yesterday"
  task update: :environment do
    updated_since = Time.current.yesterday.at_beginning_of_day.iso8601
    AccreditedProvider::Importer.call(updated_since:)
  end
end

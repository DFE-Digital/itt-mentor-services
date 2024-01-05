namespace :provider_data do
  desc "Import all Providers from Publish Teacher Training"
  task import: :environment do
    AccreditedProvider::Importer.call
  end
end


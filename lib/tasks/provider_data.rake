namespace :provider_data do
  desc "Import all Providers from Publish Teacher Training"
  task import: :environment do
    PublishTeacherTraining::Provider::Importer.call
  end
end

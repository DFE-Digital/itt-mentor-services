namespace :provider_data do
  desc "Import all Providers from Publish Teacher Training"
  task import: :environment do
    AccreditedProvider::Importer.call
  end
<<<<<<< HEAD
end
=======

  desc "Update and Add to list of Providers updated since yesterday"
  task update: :environment do

  end
end
>>>>>>> a458192 (Start Provider API services)

namespace :import_schools do
  desc "Import of schools into the claims domain"
  task :import, [:csv_file_path] => :environment do |_task, args|
    csv_file_path = args[:csv_file_path]

    Claims::ImportSchools.call(csv_file_path:)
  end
end

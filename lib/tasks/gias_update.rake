desc "Import/Update Schools using GIAS data"
task gias_update: :environment do
  Gias::SyncAllSchoolsJob.perform_now
end

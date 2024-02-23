namespace :subject_data do
  desc "Import all Subjects from Publish Teacher Training"
  task import: :environment do
    PublishTeacherTraining::Subject::Import.call
  end
end

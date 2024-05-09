desc "Update schools emails"
task update_school_emails: :environment do
  csv_string = Rails.application.encrypted("lib/data/schools_with_emails.csv.enc", env_key: "CSV_ENCRYPTION_KEY").read

  UpdateSchoolEmails.call(csv_string:)
end

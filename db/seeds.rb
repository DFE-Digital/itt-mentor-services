# Persona Creation (Dummy User Creation)
Rails.logger.debug "Creating Personas"

# Create the same personas for each service
CLAIMS_PERSONAS.each do |persona_attributes|
  User.find_or_create_by!(**persona_attributes)
end

PLACEMENTS_PERSONAS.each do |persona_attributes|
  User.find_or_create_by!(**persona_attributes)
end

Rails.logger.debug "Personas successfully created!"

Money.locale_backend = nil

Gias::SyncAllSchoolsJob.perform_now unless School.any?

School.last(2).each do |school|
  school.update!(claims_service: true)
end

School.second.update!(claims_service: true)
scope = School.where.not(claims_service: true)
scope.where(phase: "Primary").limit(2).update!(placements_service: true)
scope.where(phase: "Secondary").limit(2).update!(placements_service: true)
scope.where(phase: "All-through").first.update!(placements_service: true)

Rails.logger.debug "Services added to schools"
# Create Providers Imported from Publfish
PublishTeacherTraining::Provider::Importer.call unless Provider.any?

# Associate Placements Users with Organisations
# Single School Anne
# placements_anne = Placements::User.find_by!(email: "anne_wilson@example.org")
# placements_anne.user_memberships.find_or_create_by!(organisation: Placements::School.first)

# Provider Patrica
placements_patrica = Placements::User.find_by!(email: "patricia@example.com")
provider = Provider.first
provider.update!(placements_service: true)
placements_patrica.user_memberships.find_or_create_by!(organisation: provider)

# Multi-school Mary
placements_mary = Placements::User.find_by!(email: "mary@example.com")
schools = Placements::School.all
schools.each do |school|
  placements_mary.user_memberships.find_or_create_by!(organisation: school)
end

# Associate Claims Users with Schools
# Single School Anne
claims_anne = Claims::User.find_by!(email: "anne_wilson@example.org")
claims_anne.user_memberships.find_or_create_by!(organisation: Claims::School.first)

# Multi-school Mary
claims_mary = Claims::User.find_by!(email: "mary@example.com")
schools = Claims::School.all
schools.each do |school|
  claims_mary.user_memberships.find_or_create_by!(organisation: school)
end

# Create dummy mentors
# mentors_data = [{ first_name: "Sarah", last_name: "Doe", trn: "1234567" },
#                 { first_name: "John", last_name: "Doe", trn: "1212121" },
#                 { first_name: "Pomona", last_name: "Doe", trn: "1313131" }]
#
# mentors_data.each do |mentor|
#   Mentor.find_or_create_by!(trn: mentor[:trn]) do |new_mentor|
#     new_mentor.first_name = mentor[:first_name]
#     new_mentor.last_name = mentor[:last_name]
#   end
# end
#
# mentors = Mentor.where(trn: %w[1234567 1212121 1313131])
#
# (Claims::School.all + Placements::School.all).each do |school|
#   school.mentors = mentors
# end

# Create subjects
PublishTeacherTraining::Subject::Import.call

MODERN_LANGUAGE_SUBJECT_NAMES = ["Modern Languages",
                                 "French",
                                 "German",
                                 "Italian",
                                 "Japanese",
                                 "Mandarin",
                                 "Russian",
                                 "Spanish",
                                 "Modern languages (other)"].freeze

# Create placements
all_through_school = Placements::School.find_by(phase: "All-through")
# A school must have a school contact before creating placements
Placements::SchoolContact.create!(
  school: all_through_school,
  first_name: "School",
  last_name: "Contact",
  email_address: "itt_contact@example.com",
)

unless all_through_school.placements.any?
  primary_subjects = Subject.primary.sample(4)
  secondary_subjects = Subject.secondary.where.not(name: MODERN_LANGUAGE_SUBJECT_NAMES).sample(4)

  4.times do |i|
    year_group = Placement.year_groups.to_a.sample.first
    Placement.create!(school: all_through_school, subject: secondary_subjects[i])
    Placement.create!(school: all_through_school, subject: primary_subjects[i], year_group:)
  end
end

school_scope = School.where(claims_service: false, placements_service: false)

school_scope.where(phase: "Primary").limit(3).each do |school|
  school.update!(placements_service: true)
  Subject.primary.each do |subject|
    Placement.create!(school: school.becomes(Placements::School), subject:)
  end
end

school_scope.where(phase: "Secondary").limit(3).each do |school|
  school.update!(placements_service: true)
  Subject.secondary.where.not(name: MODERN_LANGUAGE_SUBJECT_NAMES).sample(8).each do |subject|
    Placement.create!(school: school.becomes(Placements::School), subject:)
  end
end

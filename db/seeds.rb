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
  school.update!(claims_service: true, placements_service: true)
end

School.first.update!(placements_service: true)
School.second.update!(claims_service: true)

Rails.logger.debug "Services added to schools"
# Create Providers Imported from Publfish
PublishTeacherTraining::Provider::Importer.call unless Provider.any?

# Associate Placements Users with Organisations
# Single School Anne
placements_anne = Placements::User.find_by!(email: "anne_wilson@example.org")
placements_anne.user_memberships.find_or_create_by!(organisation: Placements::School.first)

# Multi-school Mary
placements_mary = Placements::User.find_by!(email: "mary@example.com")
schools = Placements::School.all
schools.each do |school|
  placements_mary.user_memberships.find_or_create_by!(organisation: school)
end

# Provider Patrica
placements_patrica = Placements::User.find_by!(email: "patricia@example.com")
provider = Provider.first
provider.update!(placements_service: true)
placements_patrica.user_memberships.find_or_create_by!(organisation: provider)

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
mentors_data = [{ first_name: "Sarah", last_name: "Doe", trn: "1234567" },
                { first_name: "John", last_name: "Doe", trn: "1212121" },
                { first_name: "Pomona", last_name: "Doe", trn: "1313131" }]

mentors_data.each do |mentor|
  Mentor.find_or_create_by!(trn: mentor[:trn]) do |new_mentor|
    new_mentor.first_name = mentor[:first_name]
    new_mentor.last_name = mentor[:last_name]
  end
end

mentors = Mentor.where(trn: %w[1234567 1212121 1313131])

(Claims::School.all + Placements::School.all).each do |school|
  school.mentors = mentors
end

# Create subjects
PublishTeacherTraining::Subject::Import.call

# Create placements
Placements::School.find_each do |school|
  next if school.placements.any?

  placement = Placement.create!(school:, start_date: 1.month.from_now, end_date: 2.months.from_now)

  subject = school.phase == "Primary" ? Subject.primary.first : Subject.secondary.first
  PlacementSubjectJoin.create!(placement:, subject:)
  PlacementMentorJoin.create!(placement:, mentor: Placements::Mentor.first)
end

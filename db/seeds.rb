# Don't run seeds in test or production environments
return unless Rails.env.development? || HostingEnvironment.env.review?

def create_claim(school:, provider:, created_by:, reference:, status:)
  return unless mentor_remaining_hours(school:, provider:).any?

  claim = Claims::Claim.create!(
    claim_window: Claims::ClaimWindow.current,
    school:,
    provider:,
    reference:,
    created_by:,
    status:,
    submitted_at: Time.current,
    submitted_by: created_by,
  )

  assign_mentors(claim:, school:)
end

def assign_mentors(claim:, school:)
  school.mentors.each do |mentor|
    hours_completed = hours_completed(mentor:, provider: claim.provider)
    next if hours_completed.zero?

    create_mentor_training(mentor:, claim:, hours_completed:)
  end
end

def mentor_remaining_hours(school:, provider:)
  Claims::MentorsWithRemainingClaimableHoursQuery.call(
    params: {
      school:,
      provider:,
      claim: Claims::Claim.new(academic_year: Claims::ClaimWindow.current.academic_year),
    },
  )
end

def create_mentor_training(mentor:, claim:, hours_completed:)
  Claims::MentorTraining.create!(
    mentor:,
    claim: claim,
    provider: claim.provider,
    hours_completed:,
    date_completed: Time.current,
  )
end

def hours_completed(mentor:, provider:)
  training_allowance = Claims::TrainingAllowance.new(
    mentor:,
    provider:,
    academic_year: Claims::ClaimWindow.current.academic_year,
  )

  return 0 if training_allowance.remaining_hours.zero?

  rand(1..training_allowance.remaining_hours)
end

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

# Create initial claim windows
initial_claim_date = Date.parse("1 September 2023")
initial_claim_academic_year = AcademicYear.for_date(initial_claim_date)

Claims::ClaimWindow.find_or_create_by!(
  starts_on: Date.parse("2 May 2024"),
  ends_on: Date.parse("19 July 2024"),
  academic_year: initial_claim_academic_year,
)

Claims::ClaimWindow.find_or_create_by!(
  starts_on: Date.parse("29 July 2024"),
  ends_on: Date.parse("9 August 2024"),
  academic_year: initial_claim_academic_year,
)

# Create current academic year
current_date = Date.current
current_academic_year = AcademicYear.for_date(current_date)

# Create a previous and subsequent academic years
AcademicYear.for_date(current_date - 1.year)
AcademicYear.for_date(current_date + 1.year)

# Create a current claim window
Claims::ClaimWindow.find_or_create_by!(
  starts_on: Date.current.beginning_of_month,
  ends_on: Date.current.end_of_month,
  academic_year: current_academic_year,
)

Placements::Term::VALID_NAMES.each do |term_name|
  Placements::Term.find_or_create_by!(name: term_name)
end

# Create placements
placements_academic_year = current_academic_year.becomes(Placements::AcademicYear)

Placements::School.find_each do |school|
  # A school must have a school contact before creating placements
  if school.school_contact.blank?
    Placements::SchoolContact.create!(
      school:,
      first_name: "School",
      last_name: "Contact",
      email_address: "itt_contact@example.com",
    )
  end

  next if school.placements.any?

  if school.phase == "Primary"
    year_group =  Placement.year_groups.to_a.sample.first
    subject = Subject.primary.first
  else
    year_group = nil
    subject = Subject.secondary.first
  end
  placement = Placement.create!(
    school:,
    subject:,
    year_group:,
    academic_year: placements_academic_year,
  )

  PlacementMentorJoin.create!(placement:, mentor: Placements::Mentor.first)
end

# Generate claims

reference = 12_345_678
created_by = Claims::SupportUser.last
Claims::School.all.find_each do |school|
  Claims::Provider.private_beta_providers.each do |claim_provider|
    create_claim(school:,
                 provider: claim_provider,
                 created_by:,
                 reference:,
                 status: :paid)

    reference += 1

    create_claim(school:,
                 provider: claim_provider,
                 created_by:,
                 reference:,
                 status: :submitted)

    reference += 1
  end
end

# Match trainee to placement spike - temporary extension of placement trait to selected providers

provider_codes = %w[
  179 13R C59 1OV 1EL 3B6 1GX W53 1TZ 5A1
]

provider_codes.each do |code|
  provider = Provider.find_or_initialize_by(code: code)
  provider.placements_service = true
  provider.save!

  Rails.logger.info("Provider with code #{code} has placements_service set to true!")
end

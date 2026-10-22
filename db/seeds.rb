# Don't run seeds in test or production environments
return unless Rails.env.development? || HostingEnvironment.env.review?

def create_claim(school:, provider:, created_by:, reference:, status:)
  claim_window = Claims::ClaimWindow.current
  academic_year = claim_window.academic_year

  Claims::Eligibility.find_or_create_by!(school:, academic_year:)
  return unless mentor_remaining_hours(school:, provider:).any?

  claim = Claims::Claim.create!(
    claim_window:,
    school:,
    provider:,
    reference:,
    created_by:,
    status:,
    submitted_at: (Time.current unless Claims::Claim::DRAFT_STATUSES.include?(status)),
    submitted_by: (created_by unless Claims::Claim::DRAFT_STATUSES.include?(status)),
  )

  assign_mentors(claim:, school:)
  claim
end

SEED_FIXTURE_PATH = Rails.root.join("spec/fixtures/files")

def attach_csv(record, filename)
  record.csv_file.attach(
    io: File.open(SEED_FIXTURE_PATH.join(filename)),
    filename:,
    content_type: "text/csv",
  )
end

def log_claim_activity(action:, user:, record:)
  Claims::ClaimActivity.create!(action:, user:, record:)
end

PAYMENT_STATUSES = %w[payment_in_progress payment_information_requested payment_information_sent paid payment_not_approved].freeze
SAMPLING_STATUSES = %w[sampling_in_progress sampling_provider_not_approved sampling_not_approved].freeze
CLAWBACK_STATUSES = %w[clawback_requires_approval clawback_rejected clawback_requested clawback_in_progress clawback_complete].freeze

# Adds the records and fields the support and provider pages expect for each status
def seed_status_details(status:, claims:, support_user:)
  claims.each_with_index do |claim, index|
    case status
    when *PAYMENT_STATUSES then seed_payment_details(claim:, status:, index:)
    when *SAMPLING_STATUSES then seed_sampling_details(claim:, status:, index:)
    when *CLAWBACK_STATUSES then seed_clawback_details(claim:, status:, support_user:)
    end
  end

  seed_payment_record(claims:, support_user:) if PAYMENT_STATUSES.include?(status)
  seed_sampling_record(claims:, support_user:) if SAMPLING_STATUSES.include?(status)
  seed_clawback_record(claims:, support_user:) if %w[clawback_in_progress clawback_complete].include?(status)
end

def seed_payment_details(claim:, status:, index:)
  attributes = { payment_in_progress_at: (index + 1).days.ago }
  attributes[:unpaid_reason] = "Seeded reason: payer needs more information" if %w[payment_information_requested payment_information_sent payment_not_approved].include?(status)
  attributes.merge!(paid_to_la: index.odd?, date_paid: (index + 1).days.ago) if status == "paid"
  claim.update!(attributes)
end

def seed_sampling_details(claim:, status:, index:)
  claim.update!(sampling_reason: "Seeded sampling reason #{index + 1}")
  return if status == "sampling_in_progress"

  claim.update!(amendment_notification_sent_at: index.even? ? 60.days.ago : 1.day.ago) if status == "sampling_provider_not_approved"
  claim.mentor_trainings.each do |mentor_training|
    mentor_training.update!(
      not_assured: true,
      reason_not_assured: "Incorrect number of hours",
      hours_clawed_back: 1,
    )
  end
end

def seed_clawback_details(claim:, status:, support_user:)
  claim.mentor_trainings.each do |mentor_training|
    mentor_training.update!(
      not_assured: true,
      reason_not_assured: "Incorrect number of hours",
      hours_clawed_back: 1,
      reason_clawed_back: "Seeded clawback reason",
      reason_clawback_rejected: (status == "clawback_rejected" ? "Seeded reason clawback was rejected" : nil),
    )
  end

  attributes = { clawback_requested_by: support_user }
  attributes[:clawback_approved_by] = support_user if %w[clawback_requested clawback_in_progress clawback_complete].include?(status)
  claim.update!(attributes)
end

def seed_payment_record(claims:, support_user:)
  payment = Claims::Payment.create!(sent_by: support_user, claims:, downloaded_at: Time.current)
  attach_csv(payment, "example-payments.csv")
  log_claim_activity(action: :payment_request_delivered, user: support_user, record: payment)
end

def seed_sampling_record(claims:, support_user:)
  sampling = Claims::Sampling.create!
  claims.group_by(&:provider).each do |provider, provider_claims|
    provider_sampling = Claims::ProviderSampling.create!(sampling:, provider:, claims: provider_claims)
    attach_csv(provider_sampling, "example-sampling.csv")
  end
  log_claim_activity(action: :sampling_uploaded, user: support_user, record: sampling)
end

def seed_clawback_record(claims:, support_user:)
  clawback = Claims::Clawback.create!(claims:, downloaded_at: Time.current)
  attach_csv(clawback, "example-clawbacks.csv")
  log_claim_activity(action: :clawback_request_delivered, user: support_user, record: clawback)
end

# Each seeded claim uses a single mentor (the one with the most hours left),
# as mentors share one training allowance per provider across all schools
def assign_mentors(claim:, school:)
  allowances = school.mentors.map do |mentor|
    [mentor, Claims::TrainingAllowance.new(mentor:, provider: claim.provider, academic_year: claim.claim_window.academic_year, claim_to_exclude: claim)]
  end
  mentor, allowance = allowances.max_by { |_mentor, training_allowance| training_allowance.remaining_hours }
  return if allowance.blank? || allowance.remaining_hours.zero?

  create_mentor_training(mentor:, claim:, hours_completed: 1)
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
# Create Providers Imported from Publish
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
provider = Provider.first || Provider.create!(name: "Seed Provider", code: "SEED01", placements_service: true)
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

# Provider Patricia
claims_patricia = Claims::ProviderUser.find_by!(email: "patricia@example.com")
# Patricia is a member of the providers we seed claims for.
patricia_providers = Claims::Provider.private_beta_providers.order_by_name

patricia_providers.each do |provider|
  claims_patricia.user_memberships.find_or_create_by!(organisation: provider)
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
# Seeds at least CLAIMS_PER_STATUS claims of every status for accessibility testing

CLAIMS_PER_STATUS = 4

school_provider_pairs = Claims::School.all.to_a.product(patricia_providers.to_a)
reference = 12_345_678
claim_count = 0

claims_support_user = Claims::SupportUser.find_by!(email: "colin.chapman@education.gov.uk")

Claims::Claim.statuses.each_key do |status|
  claims = Array.new(CLAIMS_PER_STATUS) do
    school, claim_provider = school_provider_pairs[claim_count % school_provider_pairs.size]
    claim_count += 1

    claim = create_claim(school:,
                         provider: claim_provider,
                         created_by: claims_patricia,
                         reference:,
                         status:)
    reference += 1
    claim
  end

  seed_status_details(status:, claims: claims.compact, support_user: claims_support_user)
end

# Test providers for UR
Provider.create!(name: "Test Provider 123", code: "TEST 123")
Provider.create!(name: "Test Provider 456", code: "TEST 456")
Provider.create!(name: "Test Provider 789", code: "TEST 789")

Placements::KeyStage::VALID_NAMES.each do |name|
  Placements::KeyStage.find_or_create_by!(name:)
end

# Feature flags

Flipper.add(:school_partner_providers)

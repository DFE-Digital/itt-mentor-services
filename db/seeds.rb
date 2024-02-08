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

regions = [
  { name: "Inner London", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP") },
  { name: "Outer London", claims_funding_available_per_hour: Money.from_amount(48.25, "GBP") },
  { name: "Fringe", claims_funding_available_per_hour: Money.from_amount(45.10, "GBP") },
  { name: "Rest of England", claims_funding_available_per_hour: Money.from_amount(43.18, "GBP") },
]

regions.each do |region|
  Region.find_or_create_by(name: region[:name]) do |r|
    r.claims_funding_available_per_hour = region[:claims_funding_available_per_hour]
  end
end

region = Region.first

Rake::Task["gias_update"].invoke unless School.any?

School.last(2).each do |school|
  school.update!(claims_service: true, placements_service: true, region:)
end

School.first.update!(placements_service: true, region:)
School.second.update!(claims_service: true, region:)

Rails.logger.debug "Services added to schools"
# Create Providers Imported from Publfish
Rake::Task["provider_data:import"].invoke unless Provider.any?

Rails.logger.debug "Importing schools from GIAS..."
Rake::Task["gias_update"].invoke

# Associate Placements Users with Organisations
# Single School Anne
placements_anne = Placements::User.find_by!(email: "anne_wilson@example.org")
placements_anne.memberships.find_or_create_by!(organisation: Placements::School.first)

# Associate Claims Users with Organisations
# Single School Anne
claims_anne = Claims::User.find_by!(email: "anne_wilson@example.org")
claims_anne.memberships.find_or_create_by!(organisation: Claims::School.first)

# Multi-school Mary
placements_mary = Placements::User.find_by!(email: "mary@example.com")
schools = Placements::School.all
schools.each do |school|
  placements_mary.memberships.find_or_create_by!(organisation: school)
end

# Provider Patrica
placements_patrica = Placements::User.find_by!(email: "patricia@example.com")
provider = Provider.first
provider.update!(placements_service: true)
placements_patrica.memberships.find_or_create_by!(organisation: provider)

# Associate Claims Users with Schools
# Single School Anne
claims_anne = Claims::User.find_by!(email: "anne_wilson@example.org")
claims_anne.memberships.find_or_create_by!(organisation: Claims::School.first)

# Multi-school Mary
claims_mary = Claims::User.find_by!(email: "mary@example.com")
schools = Claims::School.all
schools.each do |school|
  claims_mary.memberships.find_or_create_by!(organisation: school)
end

# Create dummy mentors
schools = School.where(claims_service: true)
  .or(School.where(placements_service: true))
schools.each do |school|
  %w[Sarah John Pomona].each_with_index do |first_name, index|
    Mentor.find_or_create_by(
      first_name:,
      last_name: "Doe",
      school:,
      trn: index,
    )
  end
end

Rails.logger.debug "Organisations assigned to users"

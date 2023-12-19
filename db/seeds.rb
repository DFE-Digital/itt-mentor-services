SCHOOLS = [
  { claims: true },
  { placements: true },
  { claims: true, placements: true },
  { claims: true, placements: true },
].freeze

# Persona Creation (Dummy User Creation)
Rails.logger.debug "Creating Personas"

# Create the same personas for each service
CLAIMS_PERSONAS.each do |persona_attributes|
  Persona.find_or_create_by!(**persona_attributes)
end

PLACEMENTS_PERSONAS.each do |persona_attributes|
  Persona.find_or_create_by!(**persona_attributes)
end

Rails.logger.debug "Personas successfully created!"

Rake::Task["gias_update"].invoke unless GiasSchool.any?
gias_scools = GiasSchool.last(SCHOOLS.count)

SCHOOLS.each.with_index do |school_attributes, index|
  school = School.find_or_initialize_by(**school_attributes)
  school.urn = gias_scools[index].urn

  school.save!
end

User
  .where(first_name: %w[Anne Patricia])
  .find_each do |user|
    school = School.public_send(user.service).first
    user.memberships.find_or_create_by!(organisation: school)
  end

User
  .where(first_name: %w[Mary Colin])
  .find_each do |user|
    schools = School.where("#{user.service}": true)

    schools.each do |school|
      user.memberships.find_or_create_by!(organisation: school)
    end
  end

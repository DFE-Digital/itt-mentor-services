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

Rake::Task["gias_update"].invoke unless School.any?

School.last(2).each do |school|
  school.update!(claims: true, placements: true)
end

School.first.update!(placements: true)
School.second.update!(claims: true)

Rails.logger.debug "Services added to schools"

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

Rails.logger.debug "Organisations assigned to users"

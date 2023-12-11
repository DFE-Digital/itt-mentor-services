# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Persona Creation (Dummy User Creation)
Rails.logger.debug "Creating Personas"

# For each persona...
PERSONAS.each do |persona_attributes|
  # Create the persona
  Persona.find_or_create_by!(
    first_name: persona_attributes[:first_name],
    last_name: persona_attributes[:last_name],
    email: persona_attributes[:email]
  )
end

Rails.logger.debug "Personas successfully created!"

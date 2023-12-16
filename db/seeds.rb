# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Persona Creation (Dummy User Creation)
Rails.logger.debug "Creating Personas"

# Create the same personas for each service
%w[claims placements].each do |service|
  PERSONAS.each do |persona_attributes|
    Persona.find_or_create_by!(**persona_attributes, service:)
  end
end

Rails.logger.debug "Personas successfully created!"

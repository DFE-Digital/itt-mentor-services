class PersonaSignInComponent < ApplicationComponent
  attr_reader :persona

  def initialize(persona, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @persona = persona
  end

  def type_tag_colour
    case persona.first_name
    when "Anne"
      "purple"
    when "Patricia"
      "orange"
    when "Mary"
      "yellow"
    when "Colin"
      "blue"
    else
      "turquoise"
    end
  end
end

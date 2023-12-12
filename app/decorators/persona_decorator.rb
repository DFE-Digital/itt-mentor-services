class PersonaDecorator < Draper::Decorator
  delegate_all

  def type_tag_colour
    case first_name
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

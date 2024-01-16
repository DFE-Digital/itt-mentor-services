class OrganisationDecorator < Draper::Decorator
  include ActionView::Helpers::TextHelper
  delegate_all

  def formatted_address
    address_string = address_parts.reject(&:blank?)&.join("\n")
    simple_format(address_string)
  end

  def town_and_postcode
    "#{town}, #{postcode}"
  end
end

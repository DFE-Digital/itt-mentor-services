class OrganisationDecorator < Draper::Decorator
  include ActionView::Helpers::TextHelper
  delegate_all

  def formatted_address
    address_string = address_parts.reject(&:blank?)&.join("\n")
    return if address_string.blank?

    simple_format(address_string)
  end
end

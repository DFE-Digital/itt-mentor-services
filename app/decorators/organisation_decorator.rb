class OrganisationDecorator < Draper::Decorator
  include ActionView::Helpers::TextHelper
  delegate_all

  def formatted_address(wrapper_tag: "p")
    address_string = address_parts.reject(&:blank?)&.join("\n")
    return if address_string.blank?

    simple_format(address_string, {}, wrapper_tag:)
  end
end

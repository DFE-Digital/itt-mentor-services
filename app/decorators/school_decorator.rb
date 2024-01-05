class SchoolDecorator < Draper::Decorator
  delegate_all

  def formatted_address
    address_parts = [address1, address2, address3, town, postcode]
    address_parts.reject!(&:blank?)
    address_parts.join("<br/>").html_safe
  end

  def formatted_inspection_date
    last_inspection_date&.strftime("%e %B %Y")
  end
end

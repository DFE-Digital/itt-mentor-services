class SchoolDecorator < OrganisationDecorator
  def formatted_inspection_date
    return "" if last_inspection_date.blank?

    I18n.l(last_inspection_date, format: :long)
  end

  def town_and_postcode
    parts = [town, postcode].reject(&:blank?)
    parts.join(", ")
  end

  private

  def address_parts
    attributes.slice(*School::ADDRESS_FIELDS).values
  end
end

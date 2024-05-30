class SchoolDecorator < OrganisationDecorator
  def formatted_inspection_date
    return "" if last_inspection_date.blank?

    I18n.l(last_inspection_date, format: :long)
  end

  def town_and_postcode
    parts = [town, postcode].reject(&:blank?)
    parts.join(", ")
  end

  def age_range
    "#{minimum_age} to #{maximum_age}"
  end

  def percentage_free_school_meals_percentage
    "#{percentage_free_school_meals}%" if percentage_free_school_meals.present?
  end

  private

  def address_parts
    attributes.slice(*School::ADDRESS_FIELDS).values
  end
end

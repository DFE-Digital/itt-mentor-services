class SchoolDecorator < OrganisationDecorator
  attribute :transit_travel_duration
  attribute :walk_travel_duration
  attribute :drive_travel_duration

  def formatted_duration(mode)
    duration = send("#{mode}_travel_duration")
    return "" if duration.blank?

    duration.gsub(/\bmins\b/, I18n.t("components.placement.summary_component.minutes"))
  end

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

  def partner_provider_placements(provider)
    @partner_provider_placements ||= becomes(Placements::School)
      .placements
      .where(provider:)
      .decorate
  end

  private

  def address_parts
    attributes.slice(*School::ADDRESS_FIELDS).values
  end
end

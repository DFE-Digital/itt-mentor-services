module TableHelper
  def app_table(*args, **kwargs, &block)
    content_tag(:div, class: "overflow-auto") do
      govuk_table(*args, **kwargs, &block)
    end
  end

  def provider_colour(placement)
    placement.provider_name == I18n.t("placements.schools.placements.not_yet_known") ? "secondary-text" : ""
  end

  def mentor_colour(placement)
    placement.mentor_names == I18n.t("placements.schools.placements.not_yet_known") ? "secondary-text" : ""
  end
end

class OptionsFormComponent < ApplicationComponent
  OPTIONS_PER_PAGE = 15

  attr_reader :model, :url, :search_param, :records,
              :back_link, :scope, :input_field_name, :title

  def initialize(
    model:,
    url:,
    search_param:,
    records:,
    back_link:,
    scope:,
    input_field_name:,
    title:,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @model = model
    @url = url
    @search_param = search_param
    @records = records
    @back_link = back_link
    @scope = scope
    @input_field_name = input_field_name
    @title = title
  end

  def form_description
    if records.count > OPTIONS_PER_PAGE
      t(
        "components.options_form_component.paginated_form_description_html",
        record_count: OPTIONS_PER_PAGE,
        klass: records_klass,
        link_to: govuk_link_to(
          t("components.options_form_component.narrow_your_search"),
          back_link,
          no_visited_state: true,
        ),
      )
    else
      t(
        "components.options_form_component.form_description_html",
        klass: records_klass,
        link_to: govuk_link_to(
          t("components.options_form_component.change_your_search"),
          back_link,
          no_visited_state: true,
        ),
      )
    end
  end

  private

  def records_klass
    @records_klass ||= records.base_class.to_s.downcase
  end
end

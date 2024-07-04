class OptionsFormComponent < ApplicationComponent
  OPTIONS_PER_PAGE = 15

  attr_reader :model, :url, :search_param, :records, :records_klass,
              :back_link, :scope, :input_field_name, :title, :method

  def initialize(
    model:,
    url:,
    search_param:,
    records:,
    records_klass:,
    back_link:,
    scope:,
    input_field_name: :id,
    title: I18n.t("components.options_form_component.add_organisation"),
    classes: [],
    html_attributes: {},
    method: :get
  )
    super(classes:, html_attributes:)

    @model = model
    @url = url
    @search_param = search_param
    @records = records
    @records_klass = records_klass.to_s.downcase
    @back_link = back_link
    @scope = scope
    @input_field_name = input_field_name
    @title = title
    @method = method
  end

  def form_description
    if records.count > OPTIONS_PER_PAGE
      t(
        "components.options_form_component.paginated_form_description_html",
        results_count: OPTIONS_PER_PAGE,
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
end

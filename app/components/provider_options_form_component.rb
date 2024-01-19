class ProviderOptionsFormComponent < ApplicationComponent
  OPTIONS_PER_PAGE = 15

  attr_reader :model, :url, :search_param, :providers, :back_link

  def initialize(
    model:,
    url:,
    search_param:,
    providers:,
    back_link:,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @model = model
    @url = url
    @search_param = search_param
    @providers = providers
    @back_link = back_link
  end

  def form_description
    if providers.count > OPTIONS_PER_PAGE
      t(
        "components.provider_options_form_component.paginated_form_description_html",
        provider_count: OPTIONS_PER_PAGE,
        link_to: govuk_link_to(
          t("components.provider_options_form_component.narrow_your_search"),
          back_link,
          no_visited_state: true,
        ),
      )
    else
      t(
        "components.provider_options_form_component.form_description_html",
        link_to: govuk_link_to(
          t("components.provider_options_form_component.change_your_search"),
          back_link,
          no_visited_state: true,
        ),
      )
    end
  end
end

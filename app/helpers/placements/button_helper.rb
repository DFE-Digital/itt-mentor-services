module Placements::ButtonHelper
  # method extracted from get-help-with-tech service
  def govuk_start_button_link_to(url:, body: I18n.t("start_now"), html_options: {})
    options = {
      class: "govuk-button govuk-button--start #{html_options[:class]}",
      role: "button",
      data: { module: "govuk-button" },
      method: :post,
      draggable: false,
    }.merge(html_options.except(:class))

    button_to(url, options) do
      raw(%(#{body}
        <svg class="govuk-button__start-icon" xmlns="http://www.w3.org/2000/svg" width="17.5" height="19" viewBox="0 0 33 40" aria-hidden="true" focusable="false">
          <path fill="currentColor" d="M0 0h13l20 20-20 20H0l20-20z" />
        </svg>))
    end
  end
end

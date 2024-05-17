module SummaryListHelper
  def summary_row_value(
    value: nil,
    empty_text: I18n.t("helpers.summary_list_helper.not_entered")
  )
    return { text: value } if value.present?

    { text: empty_text, classes: "govuk-hint" }
  end
end

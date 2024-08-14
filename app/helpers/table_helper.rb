module TableHelper
  def app_table(*args, **kwargs, &block)
    content_tag(:div, class: "overflow-auto") do
      govuk_table(*args, **kwargs, &block)
    end
  end

  def table_text_class(data)
    data == "Not yet known" ? "secondary-text" : ""
  end
end

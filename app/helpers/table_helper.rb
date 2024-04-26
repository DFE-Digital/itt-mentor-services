module TableHelper
  def app_table(*args, **kwargs, &block)
    content_tag(:div, class: "overflow-auto") do
      govuk_table(*args, **kwargs, &block)
    end
  end
end

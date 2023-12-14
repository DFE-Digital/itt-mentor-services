class ServiceUpdate::View < GovukComponent::Base
  attr_reader :service_update

  delegate :title, :content, :date, to: :service_update

  TITLE_CLASS = "govuk-heading-m govuk-!-margin-bottom-2"

  def initialize(service_update:)
    @service_update = service_update
  end

  def title_element
    tag.h2(title, class: TITLE_CLASS)
  end

  def date_pretty
    date.to_date.strftime("%e %B %Y")
  end

  def content_html
    custom_render =
      Redcarpet::Render::HTML.new(link_attributes: { class: "govuk-link" })
    markdown = Redcarpet::Markdown.new(custom_render)
    markdown.render(content).html_safe
  end
end

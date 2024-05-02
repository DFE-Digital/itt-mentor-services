module Placements::MarkdownHelper
  def render_markdown(content)
    GovukMarkdown.render(content, headings_start_with: "l").html_safe
  end
end

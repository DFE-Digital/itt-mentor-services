module MarkdownHelper
  def render_markdown(content, headings_start_with: "l")
    GovukMarkdown.render(content, headings_start_with:).html_safe
  end
end

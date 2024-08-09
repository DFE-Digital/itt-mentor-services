module CodeHelper
  def inline_code_tag(snippet)
    render InlineCodeComponent.new(snippet)
  end
end

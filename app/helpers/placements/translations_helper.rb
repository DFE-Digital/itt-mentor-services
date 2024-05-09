module Placements::TranslationsHelper
  def embedded_link_text(translations)
    # translations.html_safe
    sanitize translations, tags: %w[a]
  end
end

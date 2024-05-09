module Placements::TranslationsHelper
  def embedded_link_text(translations)
    sanitize translations, tags: %w[a]
  end
end

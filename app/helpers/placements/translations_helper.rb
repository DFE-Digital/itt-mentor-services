module Placements::TranslationsHelper
  def embedded_link_text(translations)
    sanitize translations, tags: %w[a strong], attributes: %w[href target class]
  end
end

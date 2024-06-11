module FooterHelper
  def footer_meta_items
    {
      claims: claims_footer_meta_items,
      placements: placements_footer_meta_items,
    }.fetch current_service
  end

  private

  def claims_footer_meta_items
    [
      { text: t(".grant_conditions"), href: claims_grant_conditions_path },
      { text: t(".accessibility"), href: claims_accessibility_path },
      { text: t(".cookies"), href: claims_cookies_path },
      { text: t(".privacy_policy"), href: claims_privacy_path },
      { text: t(".terms_and_conditions"), href: claims_terms_path },
    ]
  end

  def placements_footer_meta_items
    [
      { text: t(".accessibility"), href: placements_accessibility_path },
      { text: t(".cookies"), href: placements_cookies_path },
      { text: t(".privacy_policy"), href: "#" },
      { text: t(".terms_and_conditions"), href: "#" },
    ]
  end
end

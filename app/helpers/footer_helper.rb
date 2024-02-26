module FooterHelper
  def footer_meta_items
    [
      { text: t(".guidance"), href: "#" },
      { text: t(".accessibility"), href: "#" },
      { text: t(".cookies"), href: "#" },
      { text: t(".privacy_policy"), href: "#" },
      { text: t(".terms_and_conditions"), href: "#" },
    ]
  end
end

class FooterComponentPreview < ApplicationComponentPreview
  def as_used_in_the_application
    render FooterComponent.new(meta_items:, meta_licence: false) do |footer|
      footer.with_meta_html do
        "Meta content"
      end
    end
  end

  def default
    render FooterComponent.new
  end

  def with_meta_content
    render FooterComponent.new do |footer|
      footer.with_meta_html do
        "Meta content"
      end
    end
  end

  def with_meta_items
    render FooterComponent.new(meta_items:)
  end

  def with_meta_pre_content
    render FooterComponent.new do |footer|
      footer.with_meta_pre_content do
        "Meta pre content"
      end
    end
  end

  def without_meta_licence
    render FooterComponent.new(meta_licence: false)
  end

  private

  def meta_items
    [
      { text: "Guidance", href: "#guidance" },
      { text: "Accessibility", href: "#accessibility" },
      { text: "Cookies", href: "#cookies" },
      { text: "Privacy Policy", href: "#privacy_policy" },
      { text: "Terms and Conditions", href: "#terms_and_conditions" },
    ]
  end
end

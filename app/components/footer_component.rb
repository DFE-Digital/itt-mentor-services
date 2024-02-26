class FooterComponent < GovukComponent::FooterComponent
  renders_one :meta_pre_content

  private

  def build_meta_links(links)
    return [] if links.blank?

    case links
    when Array
      links
    when Hash
      links.map do |text, href|
        { text:, href: }
      end
    else
      raise ArgumentError, "meta links must be a hash or array of hashes"
    end
  end
end

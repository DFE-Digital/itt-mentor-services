require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  it "renders the OGL licence by default" do
    render_inline described_class.new

    expect(page).to have_content("Open Government Licence v3.0")
  end

  context "when the OGL licence is disabled" do
    it "does not render the OGL licence" do
      render_inline described_class.new(meta_licence: false)

      expect(page).not_to have_content("Open Government Licence v3.0")
    end
  end

  context "when provided with meta_items" do
    it "renders a list of links" do
      meta_items = [
        { text: "GOV.UK", href: "https://gov.uk" },
        { text: "Guidance", href: "#guidance" },
      ]

      render_inline described_class.new(meta_items:)

      expect(page).to have_link("GOV.UK", href: "https://gov.uk")
      expect(page).to have_link("Guidance", href: "#guidance")
    end
  end

  context "when provided with a meta_pre_content" do
    it "renders the provided content before the licence and meta items" do
      meta_items = [
        { text: "GOV.UK", href: "https://gov.uk" },
      ]

      render_inline described_class.new(meta_items:) do |component|
        component.with_meta_pre_content do
          "This is the pre content"
        end
      end

      earlier_content = "This is the pre content"
      later_content = "GOV.UK"

      expect(page.native.to_html).to match(/#{earlier_content}.*#{later_content}/m)

      earlier_content = "This is the pre content"
      later_content = "Open Government Licence v3.0"

      expect(page.native.to_html).to match(/#{earlier_content}.*#{later_content}/m)
    end
  end

  context "when provided with meta_html" do
    it "renders the provided content after the meta items and before the licence" do
      meta_items = [
        { text: "GOV.UK", href: "https://gov.uk" },
      ]

      render_inline described_class.new(meta_items:) do |component|
        component.with_meta_html do
          "This is the meta content"
        end
      end

      earlier_content = "GOV.UK"
      later_content = "This is the meta content"

      expect(page.native.to_html).to match(/#{earlier_content}.*#{later_content}/m)

      earlier_content = "This is the meta content"
      later_content = "Open Government Licence v3.0"

      expect(page.native.to_html).to match(/#{earlier_content}.*#{later_content}/m)
    end
  end

  describe "#build_meta_links" do
    subject(:footer_component) { described_class.new }

    it "returns the original array when recieving an array" do
      meta_items = [{ text: "GOV.UK", href: "https://gov.uk" }]

      expect(footer_component.send(:build_meta_links, meta_items)).to eq(meta_items)
    end

    it "converts a hash into array of hashes" do
      meta_items = { "GOV.UK" => "https://gov.uk" }

      expect(footer_component.send(:build_meta_links, meta_items)).to eq([{ text: "GOV.UK", href: "https://gov.uk" }])
    end

    it "raises an error when provided with a non-Hash, non-Array value" do
      meta_items = "GOV.UK"

      expect { footer_component.send(:build_meta_links, meta_items) }.to raise_error ArgumentError, "meta links must be a hash or array of hashes"
    end
  end
end

require "rails_helper"

RSpec.describe FooterHelper do
  before { helper.instance_variable_set(:@virtual_path, "layouts/footer") }

  describe "#footer_meta_items" do
    context "when in claims" do
      it "returns the correct footer meta items" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
        expect(helper.footer_meta_items).to eq(
          [
            { href: "/grant-conditions", text: "Grant conditions" },
            { href: "/accessibility", text: "Accessibility" },
            { href: "/cookies", text: "Cookies" },
            { href: "/privacy", text: "Privacy notice" },
            { href: "/terms", text: "Terms and conditions" },
          ],
        )
      end
    end

    context "when in placements" do
      it "returns the correct footer meta items" do
        allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
        expect(helper.footer_meta_items).to eq(
          [
            { href: "/accessibility", text: "Accessibility" },
            { href: "/cookies", text: "Cookies" },
            { href: "/privacy", text: "Privacy notice" },
            { href: "/terms_and_conditions", text: "Terms and conditions" },
          ],
        )
      end
    end
  end
end

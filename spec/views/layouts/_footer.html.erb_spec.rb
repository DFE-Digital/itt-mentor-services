require "rails_helper"

RSpec.describe "layouts/_footer.html.erb", type: :view do
  before do
    allow(view).to receive(:current_service).and_return(:claims)
  end

  it "renders the 'Get help' panel only once" do
    render

    expect(rendered.scan("Get help").count).to eq(1)
  end

  it "renders the footer meta links" do
    render

    expect(rendered).to have_link("Grant conditions", href: "/grant-conditions")
    expect(rendered).to have_link("Accessibility", href: "/accessibility")
  end
end

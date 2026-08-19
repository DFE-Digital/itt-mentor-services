require "rails_helper"

RSpec.describe Claims::Providers::Claims::FilterFormComponent, type: :component do
  subject(:component) do
    described_class.new(
      filter_form:,
      schools: Claims::School.where(id: school.id),
      school_search_endpoint: "/providers/schools/search",
      school_search_fieldname: "claims_providers_claims_filter_form[school_ids][]",
      school_search_labelname: "claims-providers-claims-filter-form-school-ids",
    )
  end

  let(:filter_form) { Claims::Providers::Claims::FilterForm.new(index_path: "/providers/claims") }
  let!(:school) { create(:claims_school, name: "Riverbank Primary") }

  it "renders only the provider school filter" do
    render_inline(component)

    expect(page).to have_field("claims_providers_claims_filter_form[school_ids][]", with: school.id)
    expect(page).not_to have_field("claims_providers_claims_filter_form[statuses][]")
    expect(page).not_to have_field("claims_providers_claims_filter_form[search]")
    expect(page).not_to have_field("claims_providers_claims_filter_form[provider_ids][]")
  end
end

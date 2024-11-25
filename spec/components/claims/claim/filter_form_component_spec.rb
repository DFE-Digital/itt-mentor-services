require "rails_helper"

RSpec.describe Claims::Claim::FilterFormComponent, type: :component do
  subject(:component) do
    described_class.new(filter_form:)
  end

  let(:filter_form) { Claims::Support::Claims::FilterForm.new }
  let(:non_draft_statuses) { Claims::Claim.statuses.values.without(*Claims::Claim::DRAFT_STATUSES.map(&:to_s)) }

  before do
    create(:claims_provider)
    create(:claims_school)
  end

  it "renders search bar with the statuses, provider_ids, school_ids, submitted_after, and submitted_before filters" do
    render_inline(component)

    expect(page).to have_field("claims_support_claims_filter_form[search]")
    expect(page).to have_field("claims_support_claims_filter_form[statuses][]")
    expect(page).to have_field("claims_support_claims_filter_form[provider_ids][]")
    expect(page).to have_field("claims_support_claims_filter_form[school_ids][]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_after(1i)]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_after(2i)]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_after(3i)]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_before(1i)]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_before(2i)]")
    expect(page).to have_field("claims_support_claims_filter_form[submitted_before(3i)]")
  end

  it "allows users to filter by all claim statuses, except from the draft statuses" do
    render_inline(component)

    non_draft_statuses.each do |status|
      expect(page).to have_field("claims_support_claims_filter_form[statuses][]", with: status)
    end
  end

  context "when there are multiple claim window academic years" do
    before do
      create(:claim_window, :current)
      create(:claim_window, :historic)
    end

    it "renders academic year filters" do
      render_inline(component)

      expect(page).to have_field("claims_support_claims_filter_form[academic_year_ids][]")
    end
  end

  context "when provided with explicit list of statuses" do
    subject(:component) do
      described_class.new(filter_form:, statuses: filterable_statuses)
    end

    let(:filterable_statuses) { %w[submitted paid] }

    it "allows users to filter by the explicit statuses" do
      render_inline(component)

      filterable_statuses.each do |status|
        expect(page).to have_field("claims_support_claims_filter_form[statuses][]", with: status)
      end
    end

    it "does not allow users to filter by other statuses" do
      render_inline(component)

      (non_draft_statuses - filterable_statuses).each do |status|
        expect(page).not_to have_field("claims_support_claims_filter_form[statuses][]", with: status)
      end
    end
  end

  context "when provided with explicit list of providers" do
    subject(:component) do
      described_class.new(filter_form:, providers: filterable_providers)
    end

    let(:explicit_provider) { create(:claims_provider) }
    let(:filterable_providers) { Claims::Provider.where(id: explicit_provider.id) }

    it "allows users to filter by the explicit providers" do
      render_inline(component)

      filterable_providers.each do |provider|
        expect(page).to have_field("claims_support_claims_filter_form[provider_ids][]", with: provider.id)
      end
    end

    it "does not allow users to filter by other providers" do
      render_inline(component)

      (Claims::Provider.all - filterable_providers).each do |provider|
        expect(page).not_to have_field("claims_support_claims_filter_form[provider_ids][]", with: provider.id)
      end
    end
  end
end

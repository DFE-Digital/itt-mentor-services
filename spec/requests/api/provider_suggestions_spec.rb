require "rails_helper"

RSpec.describe "Provider suggestions", type: :request do
  describe "filtering NIoT providers" do
    let!(:niot_headquarters) { create(:provider, :accredited, code: "2N2", name: "NIoT") }
    let!(:niot_site_1) { create(:provider, :accredited, code: "1YF", name: "NIoT") }
    let!(:niot_site_2) { create(:provider, :accredited, code: "21J", name: "NIoT") }
    let!(:niot_site_3) { create(:provider, :accredited, code: "1GV", name: "NIoT") }
    let!(:niot_site_4) { create(:provider, :accredited, code: "2HE", name: "NIoT") }
    let!(:niot_site_5) { create(:provider, :accredited, code: "24P", name: "NIoT") }
    let!(:niot_site_6) { create(:provider, :accredited, code: "1MN", name: "NIoT") }
    let!(:niot_site_7) { create(:provider, :accredited, code: "1TZ", name: "NIoT") }
    let!(:niot_site_8) { create(:provider, :accredited, code: "5J5", name: "NIoT") }
    let!(:niot_site_9) { create(:provider, :accredited, code: "7K9", name: "NIoT") }
    let!(:niot_site_10) { create(:provider, :accredited, code: "L06", name: "NIoT") }
    let!(:niot_site_11) { create(:provider, :accredited, code: "2P4", name: "NIoT") }
    let!(:niot_site_12) { create(:provider, :accredited, code: "21P", name: "NIoT") }
    let!(:niot_site_13) { create(:provider, :accredited, code: "1FE", name: "NIoT") }
    let!(:niot_site_14) { create(:provider, :accredited, code: "3P4", name: "NIoT") }
    let!(:niot_site_15) { create(:provider, :accredited, code: "3L4", name: "NIoT") }
    let!(:niot_site_16) { create(:provider, :accredited, code: "2H7", name: "NIoT") }
    let!(:niot_site_17) { create(:provider, :accredited, code: "2A6", name: "NIoT") }
    let!(:niot_site_18) { create(:provider, :accredited, code: "4W2", name: "NIoT") }
    let!(:niot_site_19) { create(:provider, :accredited, code: "4L1", name: "NIoT") }
    let!(:niot_site_20) { create(:provider, :accredited, code: "4L3", name: "NIoT") }
    let!(:niot_site_21) { create(:provider, :accredited, code: "4C2", name: "NIoT") }
    let!(:niot_site_22) { create(:provider, :accredited, code: "5A6", name: "NIoT") }
    let!(:niot_site_23) { create(:provider, :accredited, code: "2U6", name: "NIoT") }

    describe "when requested from the claims service", service: :claims do
      let(:claims_user) { create(:claims_user) }

      before do
        Provider.find_each { |provider| Claims::ProviderEligibility.find_or_create_by!(provider:, academic_year: AcademicYear.current) }
      end

      it "does not return additional NIoT providers" do
        sign_in_as claims_user

        get "/api/provider_suggestions?query=niot"

        json = JSON.parse(response.body)
        expect(json).to eq([{ "code" => "2N2", "id" => niot_headquarters.id, "name" => "NIoT", "postcode" => nil }])
      end
    end

    describe "when requested from the placements service", service: :placements do
      let(:placements_user) { create(:placements_user) }

      it "returns all NIoT providers" do
        sign_in_as placements_user

        get "/api/provider_suggestions?query=niot"

        json = JSON.parse(response.body)
        expect(json).to contain_exactly(
          { "code" => "2N2", "id" => niot_headquarters.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "1YF", "id" => niot_site_1.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "21J", "id" => niot_site_2.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "1GV", "id" => niot_site_3.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "2HE", "id" => niot_site_4.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "24P", "id" => niot_site_5.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "1MN", "id" => niot_site_6.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "1TZ", "id" => niot_site_7.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "5J5", "id" => niot_site_8.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "7K9", "id" => niot_site_9.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "L06", "id" => niot_site_10.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "2P4", "id" => niot_site_11.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "21P", "id" => niot_site_12.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "1FE", "id" => niot_site_13.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "3P4", "id" => niot_site_14.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "3L4", "id" => niot_site_15.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "2H7", "id" => niot_site_16.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "2A6", "id" => niot_site_17.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "4W2", "id" => niot_site_18.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "4L1", "id" => niot_site_19.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "4L3", "id" => niot_site_20.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "4C2", "id" => niot_site_21.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "5A6", "id" => niot_site_22.id, "name" => "NIoT", "postcode" => nil },
          { "code" => "2U6", "id" => niot_site_23.id, "name" => "NIoT", "postcode" => nil },
        )
      end
    end
  end

  describe "filtering by eligibility for an academic year" do
    let(:academic_year) { AcademicYear.current }
    let(:other_academic_year) { AcademicYear.for_date(academic_year.ends_on + 1.day) }
    let!(:eligible_provider) { create(:provider, name: "Eligible provider", code: "EL1", accredited: false) }
    let!(:eligible_next_year_provider) { create(:provider, name: "Next year provider", code: "NY2", accredited: false) }
    let!(:accredited_only_provider) { create(:provider, name: "Accredited only provider", code: "AO3", accredited: true) }

    before do
      create(:provider, name: "Ineligible provider", code: "IN4")
      Claims::ProviderEligibility.create!(provider: eligible_provider, academic_year:)
      Claims::ProviderEligibility.create!(provider: eligible_next_year_provider, academic_year: other_academic_year)
      accredited_only_provider.eligibilities.destroy_all
    end

    def suggestions(path)
      get path
      JSON.parse(response.body).pluck("name")
    end

    describe "when requested from the claims service", service: :claims do
      let(:claims_user) { create(:claims_user) }

      before { sign_in_as claims_user }

      it "only returns providers eligible for the current academic year" do
        expect(suggestions("/api/provider_suggestions?query=provider")).to contain_exactly("Eligible provider")
      end

      it "does not depend on the accredited flag" do
        expect(suggestions("/api/provider_suggestions?query=accredited")).to be_empty
        expect(suggestions("/api/provider_suggestions?query=eligible")).to include("Eligible provider")
      end

      it "returns the providers eligible for the academic year in the path" do
        expect(suggestions("/api/academic_years/#{other_academic_year.id}/provider_suggestions?query=provider"))
          .to contain_exactly("Next year provider")
        expect(suggestions("/api/academic_years/#{academic_year.id}/provider_suggestions?query=provider"))
          .to contain_exactly("Eligible provider")
      end

      it "returns the same fields as the unscoped endpoint" do
        get "/api/academic_years/#{academic_year.id}/provider_suggestions?query=eligible"

        expect(JSON.parse(response.body).first).to eq({ "code" => "EL1", "id" => eligible_provider.id, "name" => "Eligible provider", "postcode" => nil })
      end

      it "returns nothing for an academic year with no eligible providers" do
        empty_year = AcademicYear.for_date(other_academic_year.ends_on + 1.day)

        expect(suggestions("/api/academic_years/#{empty_year.id}/provider_suggestions?query=provider")).to be_empty
      end

      it "responds as not found for an academic year that does not exist" do
        expect { get "/api/academic_years/#{SecureRandom.uuid}/provider_suggestions?query=provider" }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "when requested from the placements service", service: :placements do
      let(:placements_user) { create(:placements_user) }

      it "returns all providers regardless of eligibility" do
        sign_in_as placements_user

        expect(suggestions("/api/provider_suggestions?query=provider")).to contain_exactly(
          "Eligible provider", "Next year provider", "Accredited only provider", "Ineligible provider"
        )
      end
    end
  end
end

require "rails_helper"

RSpec.describe "Provider suggestions", type: :request do
  let!(:niot_headquarters) { create(:provider, code: "2N2", name: "NIoT") }
  let!(:niot_site_1) { create(:provider, code: "1YF", name: "NIoT") }
  let!(:niot_site_2) { create(:provider, code: "21J", name: "NIoT") }
  let!(:niot_site_3) { create(:provider, code: "1GV", name: "NIoT") }
  let!(:niot_site_4) { create(:provider, code: "2HE", name: "NIoT") }
  let!(:niot_site_5) { create(:provider, code: "24P", name: "NIoT") }
  let!(:niot_site_6) { create(:provider, code: "1MN", name: "NIoT") }
  let!(:niot_site_7) { create(:provider, code: "1TZ", name: "NIoT") }
  let!(:niot_site_8) { create(:provider, code: "5J5", name: "NIoT") }
  let!(:niot_site_9) { create(:provider, code: "7K9", name: "NIoT") }
  let!(:niot_site_10) { create(:provider, code: "L06", name: "NIoT") }
  let!(:niot_site_11) { create(:provider, code: "2P4", name: "NIoT") }
  let!(:niot_site_12) { create(:provider, code: "21P", name: "NIoT") }
  let!(:niot_site_13) { create(:provider, code: "1FE", name: "NIoT") }
  let!(:niot_site_14) { create(:provider, code: "3P4", name: "NIoT") }
  let!(:niot_site_15) { create(:provider, code: "3L4", name: "NIoT") }
  let!(:niot_site_16) { create(:provider, code: "2H7", name: "NIoT") }
  let!(:niot_site_17) { create(:provider, code: "2A6", name: "NIoT") }
  let!(:niot_site_18) { create(:provider, code: "4W2", name: "NIoT") }
  let!(:niot_site_19) { create(:provider, code: "4L1", name: "NIoT") }
  let!(:niot_site_20) { create(:provider, code: "4L3", name: "NIoT") }
  let!(:niot_site_21) { create(:provider, code: "4C2", name: "NIoT") }
  let!(:niot_site_22) { create(:provider, code: "5A6", name: "NIoT") }
  let!(:niot_site_23) { create(:provider, code: "2U6", name: "NIoT") }

  describe "when requested from the claims service", service: :claims do
    let(:claims_user) { create(:claims_user) }

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

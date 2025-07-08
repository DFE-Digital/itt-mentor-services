require "rails_helper"

RSpec.describe "Providers", service: :claims, type: :request do
  describe "GET /search" do
    let(:search_path) { search_claims_support_mentors_path(academic_year_id: academic_year.id) }
    let(:claims_support_user) { create(:claims_support_user) }
    let(:academic_year) { AcademicYear.for_date(Date.current) }

    before do
      sign_in_as claims_support_user
    end

    context "when the user is a support user" do
      it "returns a successful response" do
        get search_path

        expect(response).to have_http_status(:ok)
      end

      it "returns a list of mentors matching the query, who trained in the given academic year" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        historic_claim_window = build(:claim_window, :historic)

        mentor_1 = build(:mentor, first_name: "John", last_name: "Smith", trn: "1111111")
        mentor_2 = build(:mentor, first_name: "John", last_name: "Doe", trn: "2222222")
        mentor_3 = build(:mentor, first_name: "Sarah", last_name: "James", trn: "3333333")

        mentor_1_claim = build(:claim, :submitted, claim_window:)
        mentor_2_claim = build(:claim, :draft, claim_window:)
        mentor_3_claim = build(:claim, :submitted, claim_window: historic_claim_window)

        _mentor_1_training = create(:mentor_training, claim: mentor_1_claim, mentor: mentor_1)
        _mentor_2_training = create(:mentor_training, claim: mentor_2_claim, mentor: mentor_2)
        _mentor_3_training = create(:mentor_training, claim: mentor_3_claim, mentor: mentor_3)

        get search_path, params: { q: "John" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => mentor_1.id, "name" => mentor_1.full_name, "hint" => mentor_1.trn },
          { "id" => mentor_2.id, "name" => mentor_2.full_name, "hint" => mentor_2.trn },
        )
      end

      it "limits the number of results to a maximum of 100" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        mentors = build_list(:mentor, 105)
        claim = build(:claim, :submitted, claim_window:)

        mentors.each do |mentor|
          create(:mentor_training, claim:, mentor:)
        end

        get search_path, params: { limit: 200 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(100)
      end

      it "returns a list of mentors with a specified limit" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        mentors = build_list(:mentor, 50)
        claim = build(:claim, :submitted, claim_window:)

        mentors.each do |mentor|
          create(:mentor_training, claim:, mentor:)
        end

        get search_path, params: { limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns a list of mentors with a limit and query" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        mentors = build_list(:mentor, 50, first_name: "John")
        claim = build(:claim, :submitted, claim_window:)

        mentors.each do |mentor|
          create(:mentor_training, claim:, mentor:)
        end

        get search_path, params: { q: "John", limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns an empty array when no providers match the query" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        mentor = build(:mentor, first_name: "John")
        claim = build(:claim, :submitted, claim_window:)
        create(:mentor_training, claim:, mentor:)

        get search_path, params: { q: "Nonexistent" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq([])
      end

      it "returns a list of providers without a query" do
        claim_window = build(:claim_window, :current, academic_year: academic_year)
        mentor_1 = build(:mentor, first_name: "John", last_name: "Smith", trn: "1111111")
        mentor_2 = build(:mentor, first_name: "Sarah", last_name: "Doe", trn: "2222222")

        mentor_1_claim = build(:claim, :submitted, claim_window:)
        mentor_2_claim = build(:claim, :draft, claim_window:)

        _mentor_1_training = create(:mentor_training, claim: mentor_1_claim, mentor: mentor_1)
        _mentor_2_training = create(:mentor_training, claim: mentor_2_claim, mentor: mentor_2)

        get search_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => mentor_1.id, "name" => mentor_1.full_name, "hint" => mentor_1.trn },
          { "id" => mentor_2.id, "name" => mentor_2.full_name, "hint" => mentor_2.trn },
        )
      end
    end
  end
end

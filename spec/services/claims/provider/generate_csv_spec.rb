require "rails_helper"

RSpec.describe Claims::Provider::GenerateCsv do
  subject(:generate_csv) { described_class.call(provider:, academic_year:) }

  let!(:provider) { create(:provider) }
  let!(:academic_year) { create(:academic_year, :current) }

  it_behaves_like "a service object" do
    let(:params) do
      { provider: create(:provider), academic_year: create(:academic_year, :current) }
    end
  end

  describe "#call" do
    let(:claim_window) do
      create(:claim_window,
             academic_year:,
             starts_on: Date.parse("20 July 2024"),
             ends_on: Date.parse("30 August 2024"))
    end
    let(:another_academic_year) do
      create(:academic_year,
             name: "2024 to 2025",
             starts_on: Date.parse("1 September 2024"),
             ends_on: Date.parse("31 August 2025"))
    end
    let(:another_claim_window) do
      create(:claim_window,
             academic_year: another_academic_year,
             starts_on: Date.parse("2 May 2025"),
             ends_on: Date.parse("19 July 2025"))
    end

    let(:another_provider) { create(:provider) }

    let(:school_a) { create(:claims_school, name: "School A", postcode: "AAA AAA", urn: "1111111") }
    let(:school_b) { create(:claims_school, name: "School B", postcode: "BBB BBB", urn: "2222222") }
    let(:school_c) { create(:claims_school, name: "School C", postcode: "CCC CCC", urn: "3333333") }

    let(:mentor_1) { create(:claims_mentor, schools: [school_a], first_name: "Mentor", last_name: "A") }
    let(:mentor_2) { create(:claims_mentor, schools: [school_a], first_name: "Mentor", last_name: "B") }
    let(:mentor_3) { create(:claims_mentor, schools: [school_b], first_name: "Mentor", last_name: "C") }
    let(:mentor_4) { create(:claims_mentor, schools: [school_c], first_name: "Mentor", last_name: "D") }

    let(:claim_for_school_a_1) { create(:claim, :submitted, school: school_a, provider:, academic_year:) }
    let(:claim_for_school_a_2) { create(:claim, :submitted, school: school_a, provider:, academic_year:) }
    let(:claim_for_school_b) { create(:claim, :submitted, school: school_b, provider:, academic_year:) }
    let(:claim_for_school_c) { create(:claim, :submitted, school: school_c, provider:, academic_year:) }
    let(:claim_for_another_provider) do
      create(:claim, :submitted, school: school_c, provider: another_provider, claim_window:)
    end
    let(:claim_for_another_academic_year) do
      create(:claim, :submitted, school: school_c, provider:, claim_window: another_claim_window)
    end
    let(:draft_claim) { create(:claim, :draft, school: school_c, provider:, academic_year:) }

    let(:mentor_training_for_claim_for_school_a_1_mentor_1) do
      create(:mentor_training,
             mentor: mentor_1,
             hours_completed: 12,
             provider:,
             claim: claim_for_school_a_1)
    end
    let(:mentor_training_for_claim_for_school_a_2_mentor_2) do
      create(:mentor_training,
             mentor: mentor_2,
             hours_completed: 14,
             provider:,
             claim: claim_for_school_a_2)
    end
    let(:mentor_training_for_claim_for_school_b_mentor_3) do
      create(:mentor_training,
             mentor: mentor_3,
             hours_completed: 6,
             provider:,
             claim: claim_for_school_b)
    end
    let(:mentor_training_for_claim_for_school_c_mentor_4) do
      create(:mentor_training,
             mentor: mentor_4,
             hours_completed: 20,
             provider:,
             claim: claim_for_school_c)
    end
    let(:mentor_training_for_claim_for_another_provider_mentor_4) do
      create(:mentor_training,
             mentor: mentor_4,
             hours_completed: 20,
             provider: another_provider,
             claim: claim_for_another_provider)
    end
    let(:mentor_training_for_claim_for_another_academic_year_mentor_4) do
      create(:mentor_training,
             mentor: mentor_4,
             hours_completed: 20,
             provider:,
             claim: claim_for_another_academic_year)
    end
    let(:mentor_training_for_draft_claim) do
      create(:mentor_training,
             mentor: mentor_4,
             hours_completed: 20,
             provider:,
             claim: draft_claim)
    end

    it "returns a CSV with correct headers" do
      expect(generate_csv.lines.first.chomp).to eq(
        "school_name,school_urn,school_post_code,mentor_full_name,hours_of_training,claim_assured,claim_assured_reason",
      )
    end

    it "returns a CSV containing information related only submitted claims associated with the given provider and academic year" do
      # These claims should appear in the CSV
      mentor_training_for_claim_for_school_a_1_mentor_1
      mentor_training_for_claim_for_school_a_2_mentor_2
      mentor_training_for_claim_for_school_b_mentor_3
      mentor_training_for_claim_for_school_c_mentor_4
      # These claims should not appear in the CSV
      mentor_training_for_claim_for_another_provider_mentor_4
      mentor_training_for_claim_for_another_academic_year_mentor_4
      mentor_training_for_draft_claim

      expect(generate_csv.lines).to eq([
        "school_name,school_urn,school_post_code,mentor_full_name,hours_of_training,claim_assured,claim_assured_reason\n",
        "School A,1111111,AAA AAA,Mentor A,12\n",
        "School A,1111111,AAA AAA,Mentor B,14\n",
        "School B,2222222,BBB BBB,Mentor C,6\n",
        "School C,3333333,CCC CCC,Mentor D,20\n",
      ])
    end

    context "when a claim contains training for multiple mentors" do
      let(:mentor_training_for_mentor_1) do
        create(:mentor_training,
               mentor: mentor_1,
               hours_completed: 12,
               provider:,
               claim: claim_for_school_a_1)
      end
      let(:mentor_training_for_mentor_2) do
        create(:mentor_training,
               mentor: mentor_2,
               hours_completed: 14,
               provider:,
               claim: claim_for_school_a_1)
      end

      before do
        mentor_training_for_mentor_1
        mentor_training_for_mentor_2
      end

      it "returns a row per mentor showing the separate training hours" do
        expect(generate_csv.lines).to eq([
          "school_name,school_urn,school_post_code,mentor_full_name,hours_of_training,claim_assured,claim_assured_reason\n",
          "School A,1111111,AAA AAA,Mentor A,12\n",
          "School A,1111111,AAA AAA,Mentor B,14\n",
        ])
      end
    end

    context "when a mentor has multiple claims" do
      let(:another_claim_for_school_a_1) do
        create(:claim, :submitted, school: school_a, provider:, academic_year:)
      end
      let(:another_mentor_training_for_claim_for_school_a_1_mentor_1) do
        create(:mentor_training,
               mentor: mentor_1,
               hours_completed: 4,
               provider:,
               claim: another_claim_for_school_a_1)
      end

      before do
        mentor_training_for_claim_for_school_a_1_mentor_1
        another_mentor_training_for_claim_for_school_a_1_mentor_1
      end

      it "adds together the hours of training in each claim, and shows the total in one row per mentor" do
        expect(generate_csv.lines).to eq([
          "school_name,school_urn,school_post_code,mentor_full_name,hours_of_training,claim_assured,claim_assured_reason\n",
          "School A,1111111,AAA AAA,Mentor A,16\n",
        ])
      end
    end
  end
end

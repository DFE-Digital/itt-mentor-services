require "rails_helper"

describe Claims::Claim::Forecast do
  it_behaves_like "a service object" do
    let(:params) { { claim_window: create(:claim_window, :current) } }
  end

  describe "#call" do
    it "totals non-draft claims by group and type of establishment for the claim window" do
      claim_window = create(:claim_window, :current)
      school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
      claim = create(:claim, :submitted, school:, claim_window:)
      create(:mentor_training, claim:, hours_completed: 10)
      draft = create(:claim, :draft, school:, claim_window:)
      internal_draft = create(:claim, school:, claim_window:)
      [draft, internal_draft].each { |draft_claim| create(:mentor_training, claim: draft_claim, hours_completed: 10) }

      result = described_class.call(claim_window:)

      expect(result.groups.map(&:name)).to eq(%w[Academies])
      expect(result.groups.first.rows.map(&:type_of_establishment)).to eq(["Academy converter"])
      expect(result.groups.first.total).to eq(claim.amount)
      expect(result.total).to eq(claim.amount)
    end

    it "only totals claims with the given status when a status is provided" do
      claim_window = create(:claim_window, :current)
      school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
      submitted_claim = create(:claim, :submitted, school:, claim_window:)
      paid_claim = create(:claim, :submitted, status: :paid, school:, claim_window:)
      [submitted_claim, paid_claim].each { |claim| create(:mentor_training, claim:, hours_completed: 10) }

      result = described_class.call(claim_window:, status: :submitted)

      expect(result.groups.first.total).to eq(submitted_claim.amount)
      expect(result.total).to eq(submitted_claim.amount)
    end

    it "returns a zero total when there are no claims" do
      result = described_class.call(claim_window: create(:claim_window, :current))

      expect(result.groups).to eq([])
      expect(result.total).to eq(Money.new(0, "GBP"))
    end

    it "matches original and recovery amounts across schools, regional rates and multiple training records" do
      claim_window = create(:claim_window, :current)
      claims = [1234, 5678].map do |rate|
        region = Region.create!(name: "Forecast region #{rate}", claims_funding_available_per_hour_pence: rate)
        school = create(:claims_school, region:, group: "Academies", type_of_establishment: "Academy converter")
        claim = create(:claim, :submitted, school:, claim_window:)
        [3, 5, nil].each do |hours|
          create(:mentor_training, :not_assured, claim:, hours_completed: hours, hours_clawed_back: hours.nil? ? nil : 1)
        end
        claim
      end
      other_window = create(:claim_window, :historic)
      other_claim = create(:claim, :submitted, school: claims.first.school, claim_window: other_window)
      create(:mentor_training, claim: other_claim, hours_completed: 10)

      result = described_class.call(claim_window:)

      expect(result.groups.first.rows.size).to eq(1)
      expect(result.groups.first.rows.first.total).to eq(claims.sum(Money.new(0, "GBP"), &:amount))
      expect(result.total).to eq(Money.new((1234 + 5678) * 8, "GBP"))

      recovery = described_class.call(claim_window:, clawback: true)

      expect(recovery.total).to eq(claims.sum(Money.new(0, "GBP"), &:total_clawback_amount))
      expect(recovery.total).to eq(Money.new((1234 + 5678) * 2, "GBP"))
    end

    it "preserves zero amounts, sorted groups and rows, and missing classification behaviour" do
      claim_window = create(:claim_window, :current)
      [
        ["Local authority maintained schools", "Community school"],
        ["Academies", "Academy sponsor led"],
        ["Academies", "Academy converter"],
        ["Other", nil],
        [nil, "Community school"],
      ].each do |group, type_of_establishment|
        school = create(:claims_school, group:, type_of_establishment:)
        claim = create(:claim, :submitted, school:, claim_window:)
        create(:mentor_training, claim:, hours_completed: 10) if group.nil? || type_of_establishment.nil?
      end

      result = described_class.call(claim_window:)

      expect(result.groups.map(&:name)).to eq(["Academies", "Local authority maintained schools", "Other"])
      expect(result.groups.first.rows.map(&:type_of_establishment)).to eq(["Academy converter", "Academy sponsor led"])
      expect(result.groups.last.rows).to be_empty
      expect(result.groups.map(&:total)).to all(eq(Money.new(0, "GBP")))
      expect(result.total).to eq(Money.new(0, "GBP"))
    end

    context "when reporting clawbacks" do
      it "matches partial recovery amounts for all pending statuses, excluding other statuses and windows" do
        claim_window = create(:claim_window, :current)
        school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
        statuses = %i[clawback_requires_approval clawback_requested clawback_in_progress]
        pending_claims = statuses.map do |status|
          claim = create(:claim, :submitted, status:, school:, claim_window:)
          create(:mentor_training, :not_assured, claim:, hours_completed: 10, hours_clawed_back: 3)
          create(:mentor_training, :not_assured, claim:, hours_completed: 5, hours_clawed_back: 2)
          create(:mentor_training, :not_assured, claim:, hours_completed: nil, hours_clawed_back: nil)
          create(:mentor_training, claim:, hours_completed: 4, hours_clawed_back: 4)
          claim
        end
        %i[clawback_complete clawback_rejected sampling_not_approved submitted paid].each do |status|
          claim = create(:claim, :submitted, status:, school:, claim_window:)
          create(:mentor_training, :not_assured, claim:, hours_completed: 10, hours_clawed_back: 10)
        end
        other_claim = create(:claim, :submitted, status: :clawback_requested, school:, claim_window: create(:claim_window, :historic))
        create(:mentor_training, :not_assured, claim: other_claim, hours_completed: 10, hours_clawed_back: 10)

        result = described_class.call(claim_window:, status: statuses, clawback: true)

        expect(result.total).to eq(pending_claims.sum(Money.new(0, "GBP"), &:total_clawback_amount))
        expect(result.total).to eq(school.region_funding_available_per_hour * 15)
        expect(result.groups.first.rows.first.total).to eq(result.total)
        expect(result.groups.first.total).to eq(result.total)
      end

      it "only reports completed recoveries when selecting the completed status" do
        claim_window = create(:claim_window, :current)
        school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
        completed = create(:claim, :submitted, status: :clawback_complete, school:, claim_window:)
        pending = create(:claim, :submitted, status: :clawback_in_progress, school:, claim_window:)
        [completed, pending].each do |claim|
          create(:mentor_training, :not_assured, claim:, hours_completed: 10, hours_clawed_back: 3)
        end

        result = described_class.call(claim_window:, status: :clawback_complete, clawback: true)

        expect(result.total).to eq(completed.total_clawback_amount)
      end

      it "keeps zero-valued groups for claims without recoverable training" do
        claim_window = create(:claim_window, :current)
        school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
        create(:claim, :submitted, status: :clawback_requested, school:, claim_window:)
        claim = create(:claim, :submitted, status: :clawback_requested, school:, claim_window:)
        create(:mentor_training, claim:, hours_completed: 10, hours_clawed_back: 5)

        result = described_class.call(claim_window:, status: :clawback_requested, clawback: true)

        expect(result.groups.first.rows.first.total).to eq(Money.new(0, "GBP"))
        expect(result.total).to eq(Money.new(0, "GBP"))
      end

      it "returns a zero GBP total when there are no clawbacks" do
        result = described_class.call(claim_window: create(:claim_window, :current), status: :clawback_complete, clawback: true)

        expect(result.groups).to be_empty
        expect(result.total).to eq(Money.new(0, "GBP"))
      end
    end

    [false, true].each do |clawback|
      [1, 20].each do |count|
        it "uses one aggregate query without instantiating records for #{count} claims with clawback: #{clawback}" do
          claim_window = create(:claim_window, :current)
          school = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")
          create_list(:claim, count, :submitted, school:, claim_window:).each do |claim|
            create(:mentor_training, :not_assured, claim:, hours_completed: 10, hours_clawed_back: 3)
          end
          queries = []
          instantiations = []
          record_query = ->(event) { queries << event.payload[:sql] if event.payload[:sql].match?(/\ASELECT/i) && event.payload[:name] != "SCHEMA" }
          record_instantiation = ->(event) { instantiations << event.payload }

          ActiveRecord::Base.uncached do
            ActiveSupport::Notifications.subscribed(record_query, "sql.active_record") do
              ActiveSupport::Notifications.subscribed(record_instantiation, "instantiation.active_record") do
                described_class.call(claim_window:, clawback:)
              end
            end
          end

          expect(queries.size).to eq(1)
          expect(queries.first).to match(/SUM\(.*GROUP BY/i)
          expect(instantiations).to be_empty
        end
      end
    end
  end
end

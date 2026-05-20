module Claims
  module UserResearch
    class ProviderClaimsDemoReset
      DEMO_PROVIDER_CODE = "TEST01".freeze
      DEMO_PROVIDER_NAME = "Test provider".freeze
      DEMO_CLAIMS = [
        { reference: "90000001", status: :sampling_in_progress, training_type: :initial, academic_year: :current, claim_window_index: 0 },
        { reference: "90000002", status: :sampling_provider_not_approved, training_type: :refresher, academic_year: :current, claim_window_index: 1 },
        { reference: "90000003", status: :submitted, training_type: :initial, academic_year: :current, claim_window_index: 0 },
        { reference: "90000004", status: :paid, training_type: :refresher, academic_year: :current, claim_window_index: 1 },
        { reference: "90000005", status: :sampling_in_progress, training_type: :refresher, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000006", status: :sampling_provider_not_approved, training_type: :initial, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000007", status: :submitted, training_type: :refresher, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000008", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000009", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000010", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000011", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000012", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 1 },
      ].freeze

      def self.call
        new.call
      end

      def call
        Claims::Claim.transaction do
          provider.claims.destroy_all
          provider.update!(name: DEMO_PROVIDER_NAME)
          create_demo_claims
        end
      end

      private

      def provider
        @provider ||= Claims::Provider.find_or_create_by!(code: DEMO_PROVIDER_CODE) do |provider|
          provider.name = DEMO_PROVIDER_NAME
          provider.accredited = true
        end
      end

      def create_demo_claims
        schools = eligible_schools
        DEMO_CLAIMS.each_with_index do |claim_definition, index|
          create_demo_claim(school: schools.fetch(index % schools.count), **claim_definition)
        end
      end

      def eligible_schools
        @eligible_schools ||= Claims::School.includes(:mentors).select { |school| school.mentors.any? }.first(DEMO_CLAIMS.count)
      end

      def create_demo_claim(school:, reference:, status:, training_type:, academic_year:, claim_window_index:)
        selected_claim_window = demo_claim_window(academic_year:, claim_window_index:)

        claim = Claims::Claim.create!(
          claim_window: selected_claim_window,
          school:,
          provider:,
          reference:,
          created_by: demo_support_user,
          status:,
          submitted_at: Time.current,
          submitted_by: demo_support_user,
          sampling_reason: status == :sampling_in_progress ? "Demo audit request" : nil,
        )

        school.mentors.each do |mentor|
          hours = demo_hours_for(mentor:, provider:, academic_year: selected_claim_window.academic_year)
          next if hours.zero?

          Claims::MentorTraining.create!(
            claim:,
            mentor:,
            provider:,
            hours_completed: hours,
            training_type:,
            date_completed: Time.current,
          )
        end
      end

      def demo_hours_for(mentor:, provider:, academic_year:)
        training_allowance = Claims::TrainingAllowance.new(
          mentor:,
          provider:,
          academic_year:,
        )

        [training_allowance.remaining_hours, 5].compact.min.clamp(1, 5)
      end

      def demo_support_user
        @demo_support_user ||= Claims::SupportUser.first || Claims::SupportUser.create!(
          first_name: "Demo",
          last_name: "Support",
          email: "demo-support@education.gov.uk",
        )
      end

      def demo_claim_window(academic_year:, claim_window_index:)
        demo_claim_windows.fetch(academic_year).fetch(claim_window_index)
      end

      def demo_claim_windows
        @demo_claim_windows ||= {
          current: claim_windows_for(academic_year: AcademicYear.for_date(Date.current)),
          previous: claim_windows_for(academic_year: AcademicYear.for_date(Date.current - 1.year)),
          two_years_ago: claim_windows_for(academic_year: AcademicYear.for_date(Date.current - 2.years)),
        }
      end

      def claim_windows_for(academic_year:)
        start_year = academic_year.starts_on.year
        end_year = academic_year.ends_on.year

        window_definitions = [
          { starts_on: Date.new(start_year, 9, 1), ends_on: Date.new(start_year, 12, 31) },
          { starts_on: Date.new(end_year, 5, 1),   ends_on: Date.new(end_year, 6, 30) },
        ]

        # Build the two target windows first (restoring any previously-discarded records).
        # We skip overlap validation because we are about to discard every other window for
        # this academic year, making them invisible to the validator.
        target_windows = window_definitions.map do |defn|
          window = Claims::ClaimWindow.unscoped.find_or_initialize_by(academic_year:, starts_on: defn[:starts_on])
          window.ends_on = defn[:ends_on]
          window.discarded_at = nil
          window.save!(validate: false)
          window
        end

        # Soft-delete every other window for this academic year so that there are
        # exactly 2 windows and the overlap validator stays clean for future runs.
        Claims::ClaimWindow.unscoped
          .where(academic_year:)
          .where.not(id: target_windows.map(&:id))
          .update_all(discarded_at: Date.current)

        target_windows
      end
    end
  end
end

module Claims
  module UserResearch
    class ProviderClaimsDemoReset
      DEMO_PROVIDER_CODE = "TEST01".freeze
      DEMO_PROVIDER_NAME = "Test provider".freeze
      DEMO_MENTORS = [
        { first_name: "Alice",   last_name: "Demo", trn: "9900001" },
        { first_name: "Bob",     last_name: "Demo", trn: "9900002" },
        { first_name: "Carol",   last_name: "Demo", trn: "9900003" },
        { first_name: "David",   last_name: "Demo", trn: "9900004" },
        { first_name: "Eve",     last_name: "Demo", trn: "9900005" },
        { first_name: "Frank",   last_name: "Demo", trn: "9900006" },
      ].freeze
      DEMO_CLAIMS = [
        # Current academic year - Window 0 (Sept-Dec)
        { reference: "90000001", status: :sampling_in_progress, training_type: :initial, academic_year: :current, claim_window_index: 0 },
        { reference: "90000002", status: :submitted, training_type: :refresher, academic_year: :current, claim_window_index: 0 },
        { reference: "90000003", status: :submitted, training_type: :initial, academic_year: :current, claim_window_index: 0 },
        { reference: "90000004", status: :paid, training_type: :refresher, academic_year: :current, claim_window_index: 0 },
        { reference: "90000005", status: :sampling_in_progress, training_type: :initial, academic_year: :current, claim_window_index: 0 },
        { reference: "90000006", status: :sampling_not_approved, training_type: :refresher, academic_year: :current, claim_window_index: 0 },
        # Current academic year - Window 1 (May-June)
        { reference: "90000007", status: :sampling_provider_not_approved, training_type: :initial, academic_year: :current, claim_window_index: 1 },
        { reference: "90000008", status: :submitted, training_type: :refresher, academic_year: :current, claim_window_index: 1 },
        { reference: "90000009", status: :paid, training_type: :initial, academic_year: :current, claim_window_index: 1 },
        { reference: "90000010", status: :paid, training_type: :refresher, academic_year: :current, claim_window_index: 1 },
        { reference: "90000011", status: :sampling_in_progress, training_type: :initial, academic_year: :current, claim_window_index: 1 },
        { reference: "90000012", status: :submitted, training_type: :refresher, academic_year: :current, claim_window_index: 1 },

        # Previous academic year (2024/2025) - Window 0 (Sept-Dec)
        { reference: "90000013", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000014", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000015", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000016", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000017", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 0 },
        { reference: "90000018", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 0 },
        # Previous academic year (2024/2025) - Window 1 (May-June)
        { reference: "90000019", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000020", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000021", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000022", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000023", status: :paid, training_type: :refresher, academic_year: :previous, claim_window_index: 1 },
        { reference: "90000024", status: :paid, training_type: :initial, academic_year: :previous, claim_window_index: 1 },

        # Two years ago - Window 0 (Sept-Dec)
        { reference: "90000025", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000026", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000027", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000028", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000029", status: :sampling_not_approved, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 0 },
        { reference: "90000030", status: :sampling_not_approved, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 0 },
        # Two years ago - Window 1 (May-June)
        { reference: "90000031", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000032", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000033", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000034", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000035", status: :paid, training_type: :initial, academic_year: :two_years_ago, claim_window_index: 1 },
        { reference: "90000036", status: :paid, training_type: :refresher, academic_year: :two_years_ago, claim_window_index: 1 },
        # Extra claim requested for user research: audit required for St Gregories
        { reference: "90000037", status: :sampling_in_progress, training_type: :initial, academic_year: :current, claim_window_index: 1, school_name: "St Gregory's Catholic Primary School" },
      ].freeze

      def self.call
        new.call
      end

      def call
        Claims::Claim.transaction do
          provider.claims.destroy_all
          provider.update!(name: DEMO_PROVIDER_NAME)
          ensure_demo_mentors!
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
          fallback_school = schools.fetch(index % schools.count)
          school = school_for_claim(claim_definition, fallback_school)
          create_demo_claim(school:, **claim_definition.except(:school_name))
        end
      end

      def school_for_claim(claim_definition, fallback_school)
        return fallback_school if claim_definition[:school_name].blank?

        Claims::School.find_by("name ILIKE ?", claim_definition[:school_name]) || fallback_school
      end

      def ensure_demo_mentors!
        mentor_records = DEMO_MENTORS.map do |attrs|
          Mentor.find_or_create_by!(trn: attrs[:trn]) do |m|
            m.first_name = attrs[:first_name]
            m.last_name  = attrs[:last_name]
          end
        end

        eligible_schools.each do |school|
          school.mentors = (school.mentors + mentor_records).uniq
        end

        # Reload so school.mentors reflects the new assignments
        @eligible_schools = nil
      end

      def eligible_schools
        @eligible_schools ||= Claims::School.first(DEMO_CLAIMS.count)
      end

      def create_demo_claim(school:, reference:, status:, training_type:, academic_year:, claim_window_index:)
        selected_claim_window = demo_claim_window(academic_year:, claim_window_index:)
        submitted_at = demo_submitted_at(selected_claim_window, reference)

        claim = Claims::Claim.create!(
          claim_window: selected_claim_window,
          school:,
          provider:,
          reference:,
          created_by: demo_support_user,
          status:,
          submitted_at:,
          submitted_by: demo_support_user,
          sampling_reason: status == :sampling_in_progress ? "Demo audit request" : nil,
        )

        school.mentors.each_with_index do |mentor, mentor_index|
          # Use validate: false to bypass the training allowance cap — demo data
          # should always have mentor trainings regardless of allowance state.
          hours = ((reference.to_i + mentor_index) % 5) + 1 # 1–5 hours, varied per mentor

          mt = Claims::MentorTraining.new(
            claim:,
            mentor:,
            provider:,
            hours_completed: hours,
            training_type:,
            date_completed: submitted_at,
          )
          mt.save!(validate: false)
        end
      end

      def demo_submitted_at(claim_window, reference)
        days_offset = reference.to_i % 10 # 0–9 days into the window for variance
        claim_window.starts_on + days_offset.days
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

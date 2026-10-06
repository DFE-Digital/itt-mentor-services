require "rails_helper"

RSpec.describe "Add claim in exceptional circumstances", service: :claims, type: :request do
  let(:support_user) { create(:claims_support_user) }
  let(:claim_window) { create(:claim_window, :historic) }
  let(:school) { create(:claims_school, eligibilities: [build(:eligibility, claim_window:)]) }
  let(:provider) do
    create(:claims_provider, accredited: false).tap { |provider| Claims::ProviderEligibility.create!(provider:, academic_year: claim_window.academic_year) }
  end
  let!(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:state_key) { SecureRandom.uuid }

  let(:signed_in) { true }

  before do
    Claims::ClaimWindow.current || create(:claim_window, :current)
    sign_in_as support_user if signed_in
  end

  def put_step(step, wizard_step_param_key, attributes)
    put "/support/claims/new/#{state_key}/#{step}", params: { wizard_step_param_key => attributes }
  end

  def complete_steps_up_to_school
    put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })
    put_step(:claim_window, :claims_add_exceptional_claim_wizard_claim_window_step, { id: claim_window.id })
    put_step(:school, :claims_add_exceptional_claim_wizard_school_step, { id: school.id })
  end

  def complete_every_step(status: { status: "submitted" })
    complete_steps_up_to_school
    put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })
    put_step(:mentor, :claims_add_exceptional_claim_wizard_mentor_step, { mentor_ids: [mentor.id] })
    put_step("mentor_training_#{mentor.id}", :claims_add_claim_wizard_mentor_training_step, { mentor_id: mentor.id, hours_to_claim: "maximum" })
    put_step(:confirmation, :claims_add_claim_wizard_confirmation_step, { confirmed: true })
    put_step(:claim_status, :claims_add_exceptional_claim_wizard_claim_status_step, status)
  end

  def paid_status(date: claim_window.starts_on + 1.day, paid_to_la: "false")
    { status: "paid", paid_to_la:, "date_paid(1i)": date.year, "date_paid(2i)": date.month, "date_paid(3i)": date.day }
  end

  describe "GET /support/claims/new" do
    it "starts the journey at the exceptional circumstances step with a fresh state key" do
      get "/support/claims/new"

      expect(response).to redirect_to(%r{\Ahttp://claims\.localhost/support/claims/new/[0-9a-f-]{36}/exceptional_circumstances\z})
    end

    it "starts a different journey each time" do
      get "/support/claims/new"
      first = response.location
      get "/support/claims/new"

      expect(response.location).not_to eq(first)
    end
  end

  describe "GET /support/claims/new/:state_key/:step" do
    it "renders the exceptional circumstances warning" do
      get "/support/claims/new/#{state_key}/exceptional_circumstances"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Only add a claim for a school in exceptional circumstances")
    end

    it "has a back link to the claims list on the first step" do
      get "/support/claims/new/#{state_key}/exceptional_circumstances"

      expect(response.body).to include(%(class="govuk-back-link" href="/support/claims"))
    end

    it "has a back link to the previous step on later steps" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })
      get "/support/claims/new/#{state_key}/claim_window"

      expect(response.body).to include(%(class="govuk-back-link" href="/support/claims/new/#{state_key}/exceptional_circumstances"))
    end

    it "explains when there are no closed claim windows to choose from" do
      Claims::ClaimWindow.where(ends_on: ...Date.current).find_each(&:discard)

      get "/support/claims/new/#{state_key}/claim_window"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("There are no closed claim windows to add a claim to")
      expect(response.body).not_to include("govuk-radios")
    end

    it "only lists closed claim windows" do
      get "/support/claims/new/#{state_key}/claim_window"

      expect(response.body).to include("#{claim_window.academic_year_name} academic year")
      expect(response.body).not_to include(Claims::ClaimWindow.current.id)
    end
  end

  describe "a step that cannot be shown for the answers given so far" do
    it "restarts the journey instead of failing when a later step is requested first" do
      get "/support/claims/new/#{state_key}/check_your_answers"

      expect(response).to redirect_to("/support/claims/new")
    end

    it "restarts the journey for a step that does not exist" do
      get "/support/claims/new/#{state_key}/not_a_step"

      expect(response).to redirect_to("/support/claims/new")
    end
  end

  describe "PUT /support/claims/new/:state_key/:step" do
    it "re-renders the step with an error when the warning has not been acknowledged" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: false })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Confirm that this claim is being made under exceptional circumstances")
    end

    it "moves on to the next step when the step is valid" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })

      expect(response).to redirect_to("/support/claims/new/#{state_key}/claim_window")
    end

    it "does not accept the current claim window" do
      put_step(:claim_window, :claims_add_exceptional_claim_wizard_claim_window_step, { id: Claims::ClaimWindow.current.id })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select a claim window")
    end

    it "does not accept a claim window that does not exist" do
      put_step(:claim_window, :claims_add_exceptional_claim_wizard_claim_window_step, { id: SecureRandom.uuid })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select a claim window")
    end

    it "asks for a school when none was chosen" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })
      put_step(:claim_window, :claims_add_exceptional_claim_wizard_claim_window_step, { id: claim_window.id })
      put_step(:school, :claims_add_exceptional_claim_wizard_school_step, { id: "" })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enter a school name, unique reference number (URN) or postcode")
    end

    it "searches for schools when a name was entered instead of choosing one" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })
      put_step(:claim_window, :claims_add_exceptional_claim_wizard_claim_window_step, { id: claim_window.id })
      put_step(:school, :claims_add_exceptional_claim_wizard_school_step, { id: school.name })

      expect(response).to redirect_to("/support/claims/new/#{state_key}/school_options")
    end

    it "asks for the school to be made eligible when it is not eligible for the claim window" do
      school.eligibilities.destroy_all
      complete_steps_up_to_school

      expect(response).to redirect_to("/support/claims/new/#{state_key}/eligibility")
    end

    it "does not accept a provider that has no eligibility" do
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: create(:claims_provider, accredited: false).id })

      expect(response).to redirect_to("/support/claims/new/#{state_key}/provider_options")
    end

    it "does not accept an accredited provider that is only eligible for another academic year" do
      other_year = AcademicYear.for_date(claim_window.academic_year.ends_on + 1.day)
      other_provider = create(:claims_provider, accredited: true)
      other_provider.eligibilities.destroy_all
      Claims::ProviderEligibility.create!(provider: other_provider, academic_year: other_year)
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: other_provider.id })

      expect(response).to redirect_to("/support/claims/new/#{state_key}/provider_options")
    end

    it "accepts a provider that is eligible for the academic year of the claim window even if it is not accredited" do
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })

      expect(provider.accredited).to be(false)
      expect(response).to redirect_to("/support/claims/new/#{state_key}/mentor")
    end

    it "uses the academic year of the selected claim window for the provider lookup" do
      complete_steps_up_to_school
      get "/support/claims/new/#{state_key}/provider"

      expect(response.body).to include("/api/academic_years/#{claim_window.academic_year_id}/provider_suggestions")
    end

    it "does not accept a mentor from another school" do
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })
      put_step(:mentor, :claims_add_exceptional_claim_wizard_mentor_step, { mentor_ids: [create(:claims_mentor).id] })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select a mentor")
    end

    it "does not accept more hours than the mentor has remaining" do
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })
      put_step(:mentor, :claims_add_exceptional_claim_wizard_mentor_step, { mentor_ids: [mentor.id] })
      put_step("mentor_training_#{mentor.id}", :claims_add_claim_wizard_mentor_training_step,
               { mentor_id: mentor.id, hours_to_claim: "custom", custom_hours: 21 })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enter the number of hours between 1 and 20")
    end

    it "requires the claim status to be chosen" do
      complete_every_step(status: { status: "" })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select a claim status")
    end

    it "requires the payment details for a paid claim" do
      complete_every_step(status: { status: "paid" })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Select who the claim was paid to")
      expect(response.body).to include("Enter the date the claim was paid")
    end

    it "does not accept a date paid before the claim window opened" do
      complete_every_step(status: paid_status(date: claim_window.starts_on - 1.day))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("The date paid must not be before the claim window opened")
    end
  end

  describe "PUT /support/claims/new/:state_key/check_your_answers" do
    it "creates a submitted claim in the selected claim window" do
      complete_every_step

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.to change(Claims::Claim, :count).by(1)

      claim = Claims::Claim.last
      expect(response).to redirect_to("/support/claims/#{claim.id}")
      expect(claim).to have_attributes(status: "submitted", claim_window:, school_id: school.id, submitted_by: support_user)
    end

    it "shows a confirmation on the claim page" do
      complete_every_step
      put "/support/claims/new/#{state_key}/check_your_answers"
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Claim added")
      expect(response.body).to include("has been submitted on behalf of #{school.name}")
    end

    it "creates a paid claim with the payment details" do
      date = claim_window.starts_on + 3.days
      complete_every_step(status: paid_status(date:, paid_to_la: "true"))

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.to change(Claims::Claim, :count).by(1)

      expect(Claims::Claim.last).to have_attributes(status: "paid", paid_to_la: true, date_paid: date.in_time_zone, claim_window:)
    end

    it "shows the payment details on the claim page of a paid claim" do
      complete_every_step(status: paid_status(paid_to_la: "true"))
      put "/support/claims/new/#{state_key}/check_your_answers"
      follow_redirect!

      expect(response.body).to include("Local authority")
    end

    it "does not email anyone" do
      complete_every_step(status: paid_status)

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to have_enqueued_mail
    end

    it "does not create a second claim when the final step is submitted again" do
      complete_every_step
      put "/support/claims/new/#{state_key}/check_your_answers"

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to change(Claims::Claim, :count)
      expect(response).to redirect_to("/support/claims/new")
    end

    it "makes the school eligible and creates the claim when eligibility was confirmed" do
      school.eligibilities.destroy_all
      complete_steps_up_to_school
      put_step(:eligibility, :claims_add_exceptional_claim_wizard_eligibility_step, { confirmed: true })
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })
      put_step(:mentor, :claims_add_exceptional_claim_wizard_mentor_step, { mentor_ids: [mentor.id] })
      put_step("mentor_training_#{mentor.id}", :claims_add_claim_wizard_mentor_training_step, { mentor_id: mentor.id, hours_to_claim: "maximum" })
      put_step(:confirmation, :claims_add_claim_wizard_confirmation_step, { confirmed: true })
      put_step(:claim_status, :claims_add_exceptional_claim_wizard_claim_status_step, { status: "submitted" })

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }
        .to change(Claims::Claim, :count).by(1)
        .and change { school.eligibilities.count }.from(0).to(1)
    end

    it "does not create the claim when an earlier answer is no longer valid" do
      complete_every_step
      school.eligibilities.destroy_all

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to change(Claims::Claim, :count)

      expect(response).to redirect_to("/support/claims/new/#{state_key}/eligibility")
    end

    it "does not create the claim when the provider is no longer eligible for the academic year" do
      complete_every_step
      provider.eligibilities.destroy_all

      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to change(Claims::Claim, :count)

      expect(response).to redirect_to("/support/claims/new")
    end

    it "tells the user their answers are no longer valid" do
      complete_every_step
      school.eligibilities.destroy_all
      put "/support/claims/new/#{state_key}/check_your_answers"
      follow_redirect!

      expect(response.body).to include("Some of the answers for this claim are no longer valid")
    end
  end

  describe "add a mentor to the school" do
    let(:claim_state_key) { state_key }
    let(:mentor_state_key) { SecureRandom.uuid }
    let(:mentors_path) { "/support/claims/new/#{claim_state_key}/mentors/new" }

    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
        .with(trn: "6666666", date_of_birth: "1991-09-14")
        .and_return(
          "trn" => "6666666", "firstName" => "Edna", "middleName" => "", "lastName" => "Krabappel", "dateOfBirth" => "1991-09-14",
        )
      complete_steps_up_to_school
      put_step(:provider, :claims_add_claim_wizard_provider_step, { id: provider.id })
    end

    def put_mentor_step(step, attributes)
      put "#{mentors_path}/#{mentor_state_key}/#{step}", params: { claims_add_mentor_wizard_mentor_step: attributes }
    end

    it "starts the add mentor journey for the school chosen in the claim" do
      get mentors_path

      expect(response).to redirect_to(%r{\Ahttp://claims\.localhost#{mentors_path}/[0-9a-f-]{36}/mentor\z})
    end

    it "renders the find teacher step with a way back to the mentors in the claim" do
      get "#{mentors_path}/#{mentor_state_key}/mentor"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Find teacher")
      expect(response.body).to include(%(href="/support/claims/new/#{claim_state_key}/mentor"))
    end

    context "when the school has no mentors with hours to claim" do
      before { Claims::MentorMembership.where(school_id: school.id).destroy_all }

      it "goes back to the no mentors step" do
        get "#{mentors_path}/#{mentor_state_key}/mentor"

        expect(response.body).to include(%(href="/support/claims/new/#{claim_state_key}/no_mentors"))
      end
    end

    it "shows an error when the TRN and date of birth are missing" do
      put_mentor_step(:mentor, { trn: "" })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enter a date of birth")
    end

    it "adds the mentor to the school and returns to the mentors in the claim" do
      put_mentor_step(:mentor, { trn: "6666666", "date_of_birth(1i)": "1991", "date_of_birth(2i)": "9", "date_of_birth(3i)": "14" })
      expect(response).to redirect_to("#{mentors_path}/#{mentor_state_key}/check_your_answers")

      expect { put "#{mentors_path}/#{mentor_state_key}/check_your_answers" }
        .to change { school.reload.mentors.count }.by(1)

      expect(response).to redirect_to("/support/claims/new/#{claim_state_key}/mentor")
      follow_redirect!
      expect(response.body).to include("Edna Krabappel")
      expect(response.body).to include("Mentor added")
    end

    it "does not add a mentor who is already at the school" do
      existing = create(:claims_mentor, schools: [school], trn: "6666666")
      allow(TeachingRecord::GetTeacher).to receive(:call)
        .with(trn: "6666666", date_of_birth: "1991-09-14")
        .and_return("trn" => "6666666", "firstName" => existing.first_name, "middleName" => "", "lastName" => existing.last_name, "dateOfBirth" => "1991-09-14")

      put_mentor_step(:mentor, { trn: "6666666", "date_of_birth(1i)": "1991", "date_of_birth(2i)": "9", "date_of_birth(3i)": "14" })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("The mentor has already been added")
    end

    it "shows no results when the teacher cannot be found" do
      allow(TeachingRecord::GetTeacher).to receive(:call).and_raise(TeachingRecord::RestClient::TeacherNotFoundError)

      put_mentor_step(:mentor, { trn: "1234567", "date_of_birth(1i)": "1990", "date_of_birth(2i)": "1", "date_of_birth(3i)": "1" })

      expect(response).to redirect_to("#{mentors_path}/#{mentor_state_key}/no_results")
    end

    it "returns to the find teacher step when the confirmation step is requested before a teacher was found" do
      get "#{mentors_path}/#{mentor_state_key}/check_your_answers"

      expect(response).to redirect_to("#{mentors_path}/#{mentor_state_key}/mentor")
    end

    it "does not add a mentor when the confirmation step is submitted before a teacher was found" do
      expect { put "#{mentors_path}/#{mentor_state_key}/check_your_answers" }.not_to change(Claims::MentorMembership, :count)

      expect(response).to redirect_to("#{mentors_path}/#{mentor_state_key}/mentor")
    end

    it "restarts the add mentor journey for a step that does not exist" do
      get "#{mentors_path}/#{mentor_state_key}/not_a_step"

      expect(response).to redirect_to(mentors_path)
    end

    context "when the claim journey has no school" do
      let(:claim_state_key) { SecureRandom.uuid }

      it "redirects to the start of the journey" do
        get "#{mentors_path}/#{mentor_state_key}/mentor"

        expect(response).to redirect_to("/support/claims/new")
      end
    end
  end

  describe "authorisation" do
    let(:support_user) { create(:claims_user, schools: [school]) }
    let(:mentors_path) { "/support/claims/new/#{state_key}/mentors/new" }

    it "does not allow a school user to start the journey" do
      get "/support/claims/new"

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a school user to view a step" do
      get "/support/claims/new/#{state_key}/exceptional_circumstances"

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a school user to submit a step" do
      put_step(:exceptional_circumstances, :claims_add_exceptional_claim_wizard_exceptional_circumstances_step, { confirmed: true })

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a school user to create the claim" do
      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to change(Claims::Claim, :count)

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a school user to add a mentor through the journey" do
      get mentors_path

      expect(response).to redirect_to("/sign-in")
    end
  end

  describe "when nobody is signed in" do
    let(:signed_in) { false }

    it "does not allow the journey to be started" do
      get "/support/claims/new"

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a step to be viewed" do
      get "/support/claims/new/#{state_key}/exceptional_circumstances"

      expect(response).to redirect_to("/sign-in")
    end

    it "does not allow a claim to be created" do
      expect { put "/support/claims/new/#{state_key}/check_your_answers" }.not_to change(Claims::Claim, :count)

      expect(response).to redirect_to("/sign-in")
    end
  end
end

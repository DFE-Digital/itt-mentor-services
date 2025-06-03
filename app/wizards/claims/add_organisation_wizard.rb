module Claims
  class AddOrganisationWizard < BaseWizard
    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      if claim_windows_exist?
        add_step(NameStep)
        add_step(VendorNumberStep)
        add_step(AddSchoolWizard::ClaimWindowStep)
        add_step(RegionStep)
        add_step(AddressStep)
        add_step(ContactDetailsStep)
        add_step(CheckYourAnswersStep)
      else
        add_step(AddSchoolWizard::NoClaimWindowStep)
      end
    end

    def organisation
      @organisation ||= Claims::School.build(
        name: steps.fetch(:name).name,
        vendor_number: steps.fetch(:vendor_number).vendor_number,
        address1: steps.fetch(:address).address1,
        address2: steps.fetch(:address).address2,
        postcode: steps.fetch(:address).postcode,
        town: steps.fetch(:address).town,
        region_id: steps.fetch(:region).region_id,
        website: steps.fetch(:contact_details).website,
        telephone: steps.fetch(:contact_details).telephone,
        manually_onboarded_by: current_user,
      ).decorate
    end

    def create_organisation
      organisation.eligibilities.build(claim_window:)
      organisation.save!
    end

    def claim_window
      @claim_window ||= Claims::ClaimWindow.find(
        steps.fetch(:claim_window).claim_window_id,
      )
    end

    private

    attr_reader :current_user

    def claim_windows_exist?
      Claims::ClaimWindow.current.present? ||
        Claims::ClaimWindow.next.present?
    end
  end
end

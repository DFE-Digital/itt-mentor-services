module Claims
  class AddOrganisationWizard < BaseWizard
    def define_steps
      add_step(NameStep)
      add_step(VendorNumberStep)
      add_step(AddSchoolWizard::ClaimWindowStep)
      add_step(RegionStep)
      add_step(AddressStep)
      add_step(ContactDetailsStep)
      add_step(CheckYourAnswersStep)
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
  end
end

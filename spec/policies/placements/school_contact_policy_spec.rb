require "rails_helper"

describe Placements::SchoolContactPolicy do
  subject(:placements_school_contact_policy) { described_class }

  let(:school_contact) { Placements::SchoolContact.new(school:) }
  let(:current_user) { create(:placements_user, schools: [school]) }

  permissions :add_school_contact_journey? do
    context "when the placements school already has a school contact" do
      let(:school) { create(:placements_school) }

      it "denies access" do
        expect(placements_school_contact_policy).not_to permit(
          current_user, school_contact
        )
      end
    end

    context "when the placements school has no school contact" do
      let(:school) { create(:placements_school, with_school_contact: false) }

      it "permit access" do
        expect(placements_school_contact_policy).to permit(
          current_user, school_contact
        )
      end
    end
  end
end

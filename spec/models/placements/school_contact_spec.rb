# == Schema Information
#
# Table name: school_contacts
#
#  id            :uuid             not null, primary key
#  email_address :string           not null
#  first_name    :string
#  last_name     :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  school_id     :uuid             not null
#
# Indexes
#
#  index_school_contacts_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Placements::SchoolContact, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
  end

  describe "normalisations" do
    it { is_expected.to normalize(:name).from("  Name  ").to("Name") } # TODO: Remove when column removed
    it { is_expected.to normalize(:email_address).from("EmAiL@eXaMPlE.cOm ").to("email@example.com") }
    it { is_expected.to normalize(:first_name).from("  First name  ").to("First name") }
    it { is_expected.to normalize(:last_name).from("  Last name  ").to("Last name") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email_address) }
    it { is_expected.to allow_value("name@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("name").for(:email_address) }

    describe "#check_placement_exist" do
      let!(:school_contact) { create(:school_contact) }

      it "can not be destroyed" do
        expect { school_contact.destroy! }.to raise_error(
          ActiveRecord::RecordNotDestroyed,
          "School contact can not be destroyed!",
        )
      end
    end
  end

  describe "#full_name" do
    let(:school_contact) { build(:school_contact, first_name: "John", last_name: "Doe") }

    it "returns the full name when both first and last names are present" do
      expect(school_contact.full_name).to eq("John Doe")
    end

    it "returns the first name when only the first name is present" do
      school_contact.last_name = nil
      expect(school_contact.full_name).to eq("John")
    end

    it "returns the last name when only the last name is present" do
      school_contact.first_name = nil
      expect(school_contact.full_name).to eq("Doe")
    end

    it "returns nil when both names are absent" do
      school_contact.first_name = nil
      school_contact.last_name = nil
      expect(school_contact.full_name).to be_nil
    end
  end
end

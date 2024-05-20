require "rails_helper"

RSpec.describe Placements::Importers::SchoolUsersImporter do
  before { allow(User::Invite).to receive(:call).and_return(true) }

  it_behaves_like "a service object" do
    let(:params) { { path: "some_path_to_nowhere" } }
  end

  describe "#call" do
    let(:csv_path) { "spec/fixtures/placements/importers/school_users.csv" }

    context "when the data is valid" do
      let(:school) { create(:school, urn: "110048", placements_service: false) }

      it "onboards the school" do
        expect { described_class.call(csv_path) }.to change { school.reload.placements_service }.from(false).to(true)
      end

      it "creates users for the school" do
        expect { described_class.call(csv_path) }.to change { school.reload.users.count }.from(0).to(1)
      end

      it "creates users with the correct attributes", :aggregate_failures do
        school
        described_class.call(csv_path)
        user = school.reload.users.first

        expect(user.first_name).to eq("Jeff")
        expect(user.last_name).to eq("Barnes")
        expect(user.email).to eq("j.barnes@example.com")
      end

      it "logs the number of users imported" do
        school
        expect(Rails.logger).to receive(:info).with("1 of 4 users have been imported successfully.")

        described_class.call(csv_path)
      end

      it "does not create duplicate users" do
        school
        described_class.call(csv_path)
        expect { described_class.call(csv_path) }.not_to(change(Placements::User, :count))
      end

      it "does not send an invite to the user if they are already invited" do
        school
        described_class.call(csv_path)
        described_class.call(csv_path)
        expect(User::Invite).to have_received(:call).with(an_instance_of(Placements::User), school).once
      end

      it "sends an invite to the user" do
        school
        described_class.call(csv_path)
        expect(User::Invite).to have_received(:call).with(an_instance_of(Placements::User), school)
      end

      context "when a user is in two schools" do
        let!(:school2) { create(:school, urn: "114433", placements_service: false) }

        before do
          school
          described_class.call(csv_path)
        end

        it "associates the user to both schools" do
          user = Placements::User.find_by(email: "j.barnes@example.com")
          expect(user.schools).to match_array([school.becomes(Placements::School), school2.becomes(Placements::School)])
        end
      end
    end

    context "when the user details are not valid" do
      let!(:school) { create(:school, urn: "110063", placements_service: false) }

      before do
        create(:school, urn: "110048", placements_service: false)
        create(:school, urn: "114433", placements_service: false)
      end

      it "logs an error when a user fails to import" do
        expect(Rails.logger).to receive(:error)
          .with("Failed to import user for #{school.name}: Email address Enter an email address and Email address Enter an email address in the correct format, like name@example.com")

        described_class.call(csv_path)
      end
    end

    context "when the school is not found" do
      before do
        create(:school, urn: "110048", placements_service: false)
        create(:school, urn: "114433", placements_service: false)
      end

      it "logs an error when a school is not found" do
        expect(Rails.logger).to receive(:error).with("Failed to import users for school with URN: 110063. School not found.")

        described_class.call(csv_path)
      end
    end
  end
end

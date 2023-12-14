# spec/models/service_update_spec.rb

require "rails_helper"

RSpec.describe ServiceUpdate do
  describe ".where" do
    context "when service is :claims" do
      it "returns updates for claims" do
        allow(YAML).to receive(:load_file).and_return(
          [
            {
              date: "2023-12-14",
              title: "Claim Update",
              content: "Some content"
            }
          ]
        )
        updates = ServiceUpdate.where(service: :claims)
        expect(updates.length).to eq(1)
        expect(updates.first.title).to eq("Claim Update")
      end

      it "returns an empty hash when no updates for claims" do
        allow(YAML).to receive(:load_file).and_return(nil)
        updates = ServiceUpdate.where(service: :claims)
        expect(updates).to eq([])
      end
    end

    context "when service is :placements" do
      it "returns updates for placements" do
        allow(YAML).to receive(:load_file).and_return(
          [
            {
              date: "2023-12-14",
              title: "Placement Update",
              content: "Some content"
            }
          ]
        )
        updates = ServiceUpdate.where(service: :placements)
        expect(updates.length).to eq(1)
        expect(updates.first.title).to eq("Placement Update")
      end

      it "returns an empty hash when no updates for placements" do
        allow(YAML).to receive(:load_file).and_return(nil)
        updates = ServiceUpdate.where(service: :placements)
        expect(updates).to eq([])
      end
    end
  end

  describe ".yaml_file" do
    it "returns claims YAML file path" do
      file_path = ServiceUpdate.file_path(service: :claims)
      expect(file_path).to eq(Rails.root.join("db/claims_service_updates.yml"))
    end

    it "returns placements YAML file path" do
      file_path = ServiceUpdate.file_path(service: :placements)
      expect(file_path).to eq(
        Rails.root.join("db/placements_service_updates.yml")
      )
    end

    it "returns nil for unknown service" do
      file_path = ServiceUpdate.file_path(service: :some_other_random_service)
      expect(file_path).to be_nil
    end
  end
end

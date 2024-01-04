require "rails_helper"

RSpec.describe TeacherTrainingCourses::Provider do
  describe ".all" do
    it "makes a GET request to the API" do
      stub_providers
      expect(described_class.all).to eq []
    end
  end

  describe ".find" do
    it "gets a specific provider by its code" do
      stub_providers([
        build(:teacher_training_courses_provider, code: "T92", name: "Example provider")
      ])

      provider = described_class.find("T92")

      expect(provider).to be_a TeacherTrainingCourses::Provider
      expect(provider.code).to eq "T92"
      expect(provider.name).to eq "Example provider"
    end
  end
end

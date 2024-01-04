require "rails_helper"

RSpec.describe TeacherTrainingCourses::ApiClient do
  describe ".get" do
    it "makes a GET request to the API" do
      stub_providers
      debugger
      expect(described_class.get("/recruitment_cycles/2024/providers")).to eq("Hello")
    end
  end
end

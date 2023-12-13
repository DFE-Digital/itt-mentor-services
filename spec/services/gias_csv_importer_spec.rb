require "rails_helper"

RSpec.describe GiasCsvImporter do
  subject { described_class.call("spec/fixtures/test_gias_import.csv") }

  it "inserts the correct schools" do
    expect { subject }.to change(GiasSchool, :count).from(0).to(1)
  end

  it "updates the correct schools" do
    school = create(:gias_school, urn: "123")
    expect { subject }.to change { school.reload.name }.to "School"
  end

  it "logs messages to STDOUT" do
    expect { subject }.to output(
      match(/Done!/).and(match(/Invalid rows - /)).and(
        match(/Row 5 is invalid/)
      )
    ).to_stdout
  end
end

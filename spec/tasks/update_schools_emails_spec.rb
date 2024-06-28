require "rails_helper"
require "rake"

describe "update_emails" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  subject(:update_emails) { Rake::Task["update_school_emails"].invoke }

  let(:csv_string) { "urn,name,,establishment status,closure date,email\n105287,Fairfield Community Primary School,,Open,31/03/24,Fairfield@bury.gov.uk\n40431,Yargen Primary School,,Open,31/03/24,YARGEN@bury.gov.uk\n,,,,,\n1234,No School,,Open,31/03/24,YARGEN@bury.gov.uk" }
  let(:encrypted_mock) { instance_double(encrypted, read: csv_string) }

  it "calls Claims::ImportSchools service" do
    expect(UpdateSchoolEmails).to receive(:call)
    allow(Rails.application).to receive(:encrypted).and_return(encrypted_mock)
    update_emails
  end
end

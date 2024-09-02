require "rails_helper"

RSpec.describe GoodJob do
  # Is this test failing and you're not sure how to fix it?
  # See the GoodJob update guidance here: https://github.com/bensheldon/good_job?tab=readme-ov-file#updating
  it "does not have pending migrations" do
    expect(described_class).to be_migrated, <<~'MSG'
      GoodJob has pending database migrations
      Run `rails g good_job:update` to generate the required migrations.
      Then run `rails db:migrate` to update schema.rb
    MSG
  end
end

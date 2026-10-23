require "rails_helper"

RSpec.describe "Session store in-place changes" do
  it "persists nested session data that is mutated in place" do
    record = ActiveRecord::SessionStore::Session.create!(session_id: "abc", data: {})
    state = {}
    record.data = { "wizard" => state }
    record.save!

    reloaded = ActiveRecord::SessionStore::Session.find_by!(session_id: "abc")
    nested = reloaded.data["wizard"]
    nested["name"] = "John"
    reloaded.data = { "wizard" => nested }

    expect(reloaded).to be_changed
    reloaded.save!
    expect(ActiveRecord::SessionStore::Session.find_by!(session_id: "abc").data["wizard"]).to eq("name" => "John")
  end
end

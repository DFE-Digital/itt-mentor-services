require "rails_helper"

RSpec.describe Placements::UserPolicy do
  subject { described_class.new(current_user, user).destroy? }

  context "where current user and user are the the same user" do
    let(:current_user) { create(:placements_user) }
    let(:user) { current_user }

    it "returns false, user cannot destroy themselves" do
      expect(subject).to eq false
    end
  end

  context "where current user and user are different users" do
    let(:current_user) { create(:placements_user) }
    let(:user) { create(:placements_user) }

    it "returns true, user can destroy other users" do
      expect(subject).to eq true
    end
  end
end

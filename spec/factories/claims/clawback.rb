FactoryBot.define do
  factory :claims_clawback, class: "Claims::Clawback" do
    claims { build_list(:claim, 3, :submitted, status: :clawback_requested) }

    to_create do |clawback|
      Claims::AuditContext.set(actor: Claims::AuditContext.actor || FactoryBot.create(:claims_support_user)) { clawback.save! }
    end
  end
end

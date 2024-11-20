class AddAllClaimStatusesToClaimStatusEnum < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :claim_status, "payment_information_requested"
    add_enum_value :claim_status, "payment_information_sent"
    add_enum_value :claim_status, "paid"
    add_enum_value :claim_status, "payment_not_approved"
    add_enum_value :claim_status, "sampling_in_progress"
    add_enum_value :claim_status, "sampling_provider_not_approved"
    add_enum_value :claim_status, "sampling_not_approved"
    add_enum_value :claim_status, "clawback_requested"
    add_enum_value :claim_status, "clawback_in_progress"
    add_enum_value :claim_status, "clawback_complete"
  end
end

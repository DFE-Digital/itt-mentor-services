class RenameSentToESFAClaimStatusToPaymentInProgress < ActiveRecord::Migration[7.2]
  def change
    rename_enum_value :claim_status, from: "sent_to_esfa", to: "payment_in_progress"
  end
end

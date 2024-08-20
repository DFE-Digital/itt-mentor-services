class AddPaymentInformationSentAndPaymentNotApprovedClaimStatuses < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :claim_status, "payment_information_sent"
    add_enum_value :claim_status, "payment_not_approved"
  end
end

class AddPaidAndPaymentInformationRequestedToClaimStatus < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :claim_status, "paid"
    add_enum_value :claim_status, "payment_information_requested"
  end
end

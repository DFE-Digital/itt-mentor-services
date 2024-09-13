class AddSentToESFAToClaimStatusEnum < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :claim_status, "sent_to_esfa"
  end
end

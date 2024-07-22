class AddClaimWindowToClaims < ActiveRecord::Migration[7.1]
  def up
    date = Date.parse("2 May 2024")
    claim_window = Claims::ClaimWindow.find_by_date(date)

    Claims::Claim.update_all(claim_window_id: claim_window.id) if claim_window
  end

  def down
    Claims::Claim.update_all(claim_window_id: nil)
  end
end

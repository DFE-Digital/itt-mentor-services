class PopulateClaimWindows < ActiveRecord::Migration[7.1]
  def up
    claim_window = Claims::ClaimWindow::Build.call(
      claim_window_params: {
        starts_on: Date.parse("2 May 2024"),
        ends_on: Date.parse("19 July 2024"),
      },
    )

    claim_window.save!(validate: false)
  end

  def down
    Claims::ClaimWindow.where(starts_on: Date.parse("2 May 2024"), ends_on: Date.parse("19 July 2024")).destroy_all
  end
end

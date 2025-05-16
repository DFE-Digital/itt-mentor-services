class AddSendToPlacements < ActiveRecord::Migration[7.2]
  def change
    add_column :placements, :send_specific, :boolean, default: false
  end
end

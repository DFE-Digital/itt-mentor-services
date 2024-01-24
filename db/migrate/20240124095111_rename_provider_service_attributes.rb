class RenameProviderServiceAttributes < ActiveRecord::Migration[7.1]
  def change
    change_table :providers do |t|
      t.rename :placements, :placements_service
    end
  end
end

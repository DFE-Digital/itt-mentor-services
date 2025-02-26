class AddCourseMatchesToPlacements < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :placement_courses, :placement, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end

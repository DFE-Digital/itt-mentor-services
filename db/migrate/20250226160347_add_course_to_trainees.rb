class AddCourseToTrainees < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :trainees, :course, type: :uuid, index: { algorithm: :concurrently }
  end
end

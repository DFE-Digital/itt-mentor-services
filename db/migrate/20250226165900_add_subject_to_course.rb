class AddSubjectToCourse < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :courses, :subject, type: :uuid, index: { algorithm: :concurrently }
  end
end

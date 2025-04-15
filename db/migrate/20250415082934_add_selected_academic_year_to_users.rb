class AddSelectedAcademicYearToUsers < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :users, :selected_academic_year, type: :uuid, index: { algorithm: :concurrently }
  end
end

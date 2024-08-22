class AddAcademicYearRefToPlacements < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :placements, :academic_year, null: false, type: :uuid, index: {algorithm: :concurrently}
  end
end
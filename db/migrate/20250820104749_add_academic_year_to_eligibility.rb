class AddAcademicYearToEligibility < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :eligibilities, :academic_year, type: :uuid, index: { algorithm: :concurrently }
  end
end

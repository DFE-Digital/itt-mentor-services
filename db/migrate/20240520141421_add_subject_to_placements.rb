class AddSubjectToPlacements < ActiveRecord::Migration[7.1]
  def change
    StrongMigrations.disable_check(:add_reference)

    add_reference :placements, :subject, type: :uuid, foreign_key: true
  end
end

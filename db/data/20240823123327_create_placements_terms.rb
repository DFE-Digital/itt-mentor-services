class CreatePlacementsTerms < ActiveRecord::Migration[7.1]
  def up
    Placements::Term::VALID_NAMES.each do |term_name|
      Placements::Term.find_or_create_by!(name: term_name)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

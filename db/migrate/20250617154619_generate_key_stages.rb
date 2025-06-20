class GenerateKeyStages < ActiveRecord::Migration[8.0]
  def up
    Placements::KeyStage::VALID_NAMES.each do |name|
      Placements::KeyStage.find_or_create_by!(name:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

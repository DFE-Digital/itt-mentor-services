class PopulateAcademicYears < ActiveRecord::Migration[7.1]
  def up
    2023.upto(2025).each do |year|
      AcademicYear.create_with(
        starts_on: Date.new(year, 9, 1),
        ends_on: Date.new(year + 1, 8, 31),
      ).find_or_create_by!(name: "#{year} to #{year + 1}")
    end
  end

  def down
    AcademicYear.where(name: ["2023 to 2024", "2024 to 2025", "2025 to 2026"]).destroy_all
  end
end

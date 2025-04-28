class Placements::ImportPreviouslyOfferedPlacementsJob < ApplicationJob
  queue_as :default

  def perform(csv_path)
    return if csv_path.blank?

    CSV.foreach(csv_path, headers: true) do |row|
      school = School.find_by(urn: row["school_urn"])
      number_of_placements = row["number_of_placements"]
      next if school.blank? || number_of_placements.to_i.zero?

      school.update!(previously_offered_placements: true)
    end
  end
end

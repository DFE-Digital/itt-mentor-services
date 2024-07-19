class UpdateRestOfEnglandHourlyRate < ActiveRecord::Migration[7.1]
  def up
    return if rest_of_england.nil?

    # Update to the correct hourly rate
    rest_of_england.claims_funding_available_per_hour = 43.80
    rest_of_england.save!
  end

  def down
    return if rest_of_england.nil?

    # Revert to the previous (incorrect) hourly rate
    rest_of_england.claims_funding_available_per_hour = 43.18
    rest_of_england.save!
  end

  private

  def rest_of_england
    @rest_of_england ||= Region.find_by(name: "Rest of England")
  end
end

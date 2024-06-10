class SplitSchoolContactNameIntoFirstAndLastName < ActiveRecord::Migration[7.1]
  def up
    return unless Placements::SchoolContact.column_names.include?("name")

    Placements::SchoolContact.where(first_name: nil, last_name: nil).find_each do |school_contact|
      first_name, *last_names = school_contact.name.split
      school_contact.update!(first_name:, last_name: last_names.join(" "))
    end
  end

  def down
    return unless Placements::SchoolContact.column_names.include?("name")

    Placements::SchoolContact.update_all(first_name: nil, last_name: nil)
  end
end

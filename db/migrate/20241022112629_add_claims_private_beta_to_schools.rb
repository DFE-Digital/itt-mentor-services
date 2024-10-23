class AddClaimsPrivateBetaToSchools < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :claims_private_beta, :boolean, default: false

    up_only do
      Claims::School.find_each do |school|
        school.update!(claims_private_beta: true)
      end
    end
  end
end

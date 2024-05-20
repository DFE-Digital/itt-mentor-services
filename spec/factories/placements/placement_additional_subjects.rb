# == Schema Information
#
# Table name: placement_additional_subjects
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  placement_id :uuid             not null
#  subject_id   :uuid             not null
#
# Indexes
#
#  index_placement_additional_subjects_on_placement_id  (placement_id)
#  index_placement_additional_subjects_on_subject_id    (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (placement_id => placements.id)
#  fk_rails_...  (subject_id => subjects.id)
#
FactoryBot.define do
  factory :placement_additional_subject, class: "Placements::PlacementAdditionalSubject" do
  end
end

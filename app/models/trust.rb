# == Schema Information
#
# Table name: trusts
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trusts_on_uid  (uid) UNIQUE
#
class Trust < ApplicationRecord
  validates :uid, :name, presence: true
  validates :uid, uniqueness: { case_sensitive: false }

  has_many :schools
end

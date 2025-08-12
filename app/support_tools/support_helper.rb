class SupportHelper
  def self.deactivate_school(school:, claims_service: false, placements_service: false)
    ApplicationRecord.transaction do
      if claims_service
        claims_school = school.becomes(Claims::School).includes(:claims)
        if claims_school.claims.where.not(status: Claims::Claim::ACTIVE_STATUSES).present?
          raise "School has claims not in draft or submitted. School can not be offboarded."
        else
          claims_school.claims.destroy_all
          claims_school.eligibilities.destroy_all
          claims_school.mentor_memberships.destroy_all
          claims_school.user_memberships.destroy_all

          claims_school.update!(claims_service: false)
        end
      end

      if placements_service
        placements_school = school.becomes(Placements::School)
        if placements_school.placements.where.not(provider_id: nil).present?
          raise "School has placements assigned to providers. School can not be offboarded."
        else
          placements_school.placements.destroy_all
          placements_school.mentor_memberships.destroy_all
          placements_school.partnerships.destroy_all
          placements_school.user_memberships.destroy_all
          placements_school.hosting_interests.destroy_all

          placements_school.update!(placements_service: false)
        end
      end
    end
  end
end

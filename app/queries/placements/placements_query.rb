module Placements
  class PlacementsQuery
    include Filterable

    def self.filter(filters:, scope: nil)
      new(scope).filter_by(filters)
    end

    def initialize(scope)
      @scope = scope || Placement.all
    end

    private

    def by_status(status, scope)
      scope.where(status:)
    end

    # Subject filters

    def by_subject_id(subject_id, scope)
      scope.joins(:subjects).where(subjects: { id: subject_id })
    end

    # School filters

    def by_school_type(school_type, scope)
      scope.joins(:school).where(schools: { type_of_establishment: school_type })
    end

    def by_gender(gender, scope)
      scope.joins(:school).where(schools: { gender: })
    end

    def by_religious_character(religious_character, scope)
      scope.joins(:school).where(schools: { religious_character: })
    end

    def by_ofsted_rating(ofsted_rating, scope)
      scope.joins(:school).where(schools: { rating: ofsted_rating })
    end

    def by_name_urn_postcode(name_urn_postcode, scope)
      schools = School.search_name_urn_postcode(name_urn_postcode)
      scope.where(school_id: schools.pluck(:id))
    end
  end
end

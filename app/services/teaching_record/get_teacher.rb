module TeachingRecord
  class GetTeacher
    include ServicePattern

    def initialize(trn:, date_of_birth: nil)
      @trn = trn
      @date_of_birth = date_of_birth
    end

    def call
      RestClient.get("teachers/#{trn}#{query_params}")
    end

    attr_reader :trn, :date_of_birth

    private

    def query_params
      date_of_birth.blank? ? "" : "?#{date_of_birth.to_query("dateOfBirth")}"
    end
  end
end

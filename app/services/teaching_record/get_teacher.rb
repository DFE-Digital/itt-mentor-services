module TeachingRecord
  class GetTeacher
    include ServicePattern

    def initialize(trn:)
      @trn = trn
    end

    def call
      RestClient.get("/v3/teachers/#{trn}")
    end

    attr_reader :trn
  end
end

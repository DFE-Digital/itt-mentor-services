module Dqt
  class GetTeacher
    include ServicePattern

    def initialize(trn:)
      @trn = trn
    end

    def call
      Client.get("/v3/teachers/#{trn}")
    end

    attr_reader :trn
  end
end

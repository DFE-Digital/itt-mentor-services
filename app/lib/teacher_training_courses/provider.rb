module TeacherTrainingCourses
  class Provider
    ATTRIBUTES = %i[code name email website ukprn accredited_body].freeze

    attr_reader(*ATTRIBUTES)

    def initialize(_code, attributes)
      ATTRIBUTES.each do |attribute|
        attribute = attribute.to_s
        instance_variable_set("@#{attribute}", attributes[attribute])
      end
    end

    class << self
      def all
        providers_from_api.map { |code, attributes| new(code, attributes) }
      end

      def find(code)
        if (attributes = providers_from_api[code])
          new(code, attributes)
        else
          raise ProviderNotFound, code
        end
      end

      private

      def providers_from_api
        @providers_from_api ||= Rails.cache.fetch("providers_from_api", expires_in: 1.hour) do
          # Fetch all providers from the Teacher Training Courses API
          providers = ApiClient.get_all_pages("/recruitment_cycles/2024/providers")

          # Drop attributes we don't need
          providers = providers.map do |provider|
            provider["attributes"].select { |key, _value| ATTRIBUTES.include?(key.to_sym) }
          end

          # Transform to a Hash indexed by provider code
          providers.index_by { |provider| provider["code"] }
        end
      end
    end

    class ProviderNotFound < StandardError
      def initialize(code)
        super("Couldn't find provider with code '#{code}'")
      end
    end
  end
end

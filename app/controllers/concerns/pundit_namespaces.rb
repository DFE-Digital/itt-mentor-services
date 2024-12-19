module PunditNamespaces
  extend ActiveSupport::Concern

  included do
    def unwrap_pundit_scope(scope)
      scope.is_a?(Array) ? scope : [scope]
    end
  end

  class_methods do
    def append_pundit_namespace(*namespaces)
      define_method :authorize do |record, query = nil, policy_class: nil|
        super([*namespaces, *unwrap_pundit_scope(record)], query, policy_class:)
      end

      define_method :policy do |record|
        super([*namespaces, *unwrap_pundit_scope(record)])
      end

      define_method :pundit_policy_scope do |scope|
        super([*namespaces, *unwrap_pundit_scope(scope)])
      end

      private :pundit_policy_scope
    end
  end
end

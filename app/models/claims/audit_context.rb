class Claims::AuditContext < ActiveSupport::CurrentAttributes
  class MissingActor < StandardError; end

  attribute :actor, :system_operation, :source, :operation_id

  def self.validate!
    return if actor&.persisted? && !actor.destroyed? && actor.class.exists?(actor.id)
    return if actor.nil? && system_operation.present?

    raise MissingActor, "Claim status changes require a persisted actor or an explicitly named system operation"
  end
end

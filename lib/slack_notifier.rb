class SlackNotifier
  class_attribute :endpoint_url

  private_class_method :new

  def message(text: nil, blocks: nil)
    Message.new(endpoint_url:, text:, blocks:)
  end

  def self.method_missing(method, *args, **kwargs)
    if public_method_defined?(method, false)
      new.public_send(method, *args, **kwargs)
    else
      super
    end
  end

  def self.respond_to_missing?(method, _include_private = false)
    public_method_defined?(method, false)
  end

  class Message
    attr_reader :endpoint_url, :text, :blocks

    def initialize(endpoint_url:, text:, blocks: nil)
      @endpoint_url = endpoint_url
      @text = text
      @blocks = blocks
    end

    def deliver_now
      return unless endpoint_url

      HTTParty.post(endpoint_url, body: body.to_json)
    end

    def deliver_later
      DeliveryJob.perform_later(endpoint_url, text, blocks)
    end

    class DeliveryJob < ApplicationJob
      def perform(endpoint_url, text, blocks)
        Message.new(endpoint_url:, text:, blocks:).deliver_now
      end
    end

    private

    def body
      {
        text:,
        blocks:,
      }
    end
  end
end

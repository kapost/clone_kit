# frozen_string_literal: true

module CloneKit
  class EventOutlet
    if defined?(Rails)
      delegate :info, :warn, :error, to: :rails_logger
    else
      def info(message)
        puts message
      end

      def warn(message)
        puts message
      end

      def error(message)
        puts message
      end
    end

    private

    def rails_logger
      Rails.logger
    end
  end
end

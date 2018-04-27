# frozen_string_literal: true

module CloneKit
  class Rule
    attr_accessor :id_generator

    def initialize(id_generator: nil)
      @id_generator = id_generator
    end

    def current_operation=(operation)
      @shared_id_map = nil
      @current_operation = operation
    end

    protected

    attr_reader :current_operation

    def operation_arguments
      current_operation.arguments
    end

    def shared_id_map
      @shared_id_map ||= CloneKit::SharedIdMap.new(current_operation.id)
    end

    def warn_event(message)
      current_operation.warn(message)
    end

    def error_event(message)
      current_operation.error(message)
    end
  end
end

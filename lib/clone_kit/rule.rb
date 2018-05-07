# frozen_string_literal: true

module CloneKit
  class Rule
    attr_accessor :id_generator

    def initialize(id_generator: nil, id_map_class: CloneKit::SharedIdMap)
      @id_generator = id_generator
      @id_map_class = id_map_class
    end

    def current_operation=(operation)
      @shared_id_map = nil
      @current_operation = operation
    end

    protected

    attr_reader :current_operation, :id_map_class

    def operation_arguments
      current_operation.arguments
    end

    def shared_id_map
      @shared_id_map ||= id_map_class.new(current_operation.id)
    end

    def warn_event(message)
      current_operation.warn(message)
    end

    def error_event(message)
      current_operation.error(message)
    end
  end
end

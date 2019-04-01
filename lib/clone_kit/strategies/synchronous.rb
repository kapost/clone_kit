# frozen_string_literal: true

module CloneKit
  module Strategies
    class Synchronous
      def initialize(operation)
        self.operation = operation
      end

      def all_batches_complete
        # NOP
      end

      def clone_next_batch(model_specs, complete_handler)
        model_specs.each do |spec|
          spec.cloner.clone_ids(spec.emitter.scope(operation.arguments).pluck(:id), operation)
        end

        complete_handler.new.complete(
          true,
          "operation" => {
            already_cloned: operation.already_cloned + model_specs.map(&:model).map(&:to_s),
            id: operation.id,
            arguments: operation.arguments,
            strategy: self.class
          }
        )
      end

      attr_accessor :operation
    end
  end
end

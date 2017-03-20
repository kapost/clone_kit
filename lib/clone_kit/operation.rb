# frozen_string_literal: true

require "forwardable"
require "securerandom"
require "clone_kit/event_outlet"
require "clone_kit/strategies/synchronous"

module CloneKit
  class Operation
    extend Forwardable

    attr_reader :id,
                :arguments,
                :already_cloned

    def initialize(arguments: {},
                   id: SecureRandom.uuid,
                   already_cloned: [],
                   strategy: Strategies::Synchronous,
                   event_outlet: CloneKit::EventOutlet.new)
      self.id = id
      self.arguments = arguments
      self.already_cloned = already_cloned
      self.event_outlet = event_outlet
      self.strategy = strategy.new(self)
    end

    def process
      if next_batch.empty?
        # Done!
        after_process
      elsif first_unspecified_model_dependency.present?
        fail "A clone dependency was added for #{first_unspecified_model_dependency}, but it has no clone specification"
      else
        specs = next_batch.map { |model| CloneKit.spec[model] }
        strategy.clone_next_batch(specs, BatchCompleteHandler)
      end
    end

    def_delegators :event_outlet, :info, :warn, :error

    private

    attr_accessor :strategy,
                  :event_outlet

    attr_writer :id,
                :arguments,
                :already_cloned

    def after_process
      CloneKit.graph.nodes.each do |model, _|
        CloneKit.spec[model].after_operation_block.call(self)
      end

      strategy.all_batches_complete
    end

    def next_batch
      @next_batch ||= CloneKit.cloneable_models(already_cloned)
    end

    def first_unspecified_model_dependency
      next_batch.detect { |model| CloneKit.spec[model].nil? }
    end

    class BatchCompleteHandler
      def complete(success, options)
        op = Operation.new(options.fetch("operation"))

        if success
          op.process
        else
          op.error(options.fetch("failure_message", "Unknown error"))
        end
      end
    end
  end
end

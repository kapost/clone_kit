# frozen_string_literal: true

require "clone_kit/emitters/empty"
require "clone_kit/cloners/no_op"

module CloneKit
  class SpecificationError < StandardError; end

  class Specification
    attr_accessor :model,
                  :emitter,
                  :cloner,
                  :dependencies,
                  :after_operation_block

    EMPTY_EMITTER = Emitters::Empty.new
    NO_OP_CLONER = Cloners::NoOp.new

    def initialize(model, &block)
      self.model = model
      self.emitter = EMPTY_EMITTER
      self.cloner = NO_OP_CLONER
      self.dependencies = []
      self.after_operation_block = -> (_op) {}

      validate!

      model.instance_exec(self, &block)

      CloneKit.add_specification(self)
    end

    def after_operation(&block)
      self.after_operation_block = block
    end

    private

    def validate!
      fail SpecificationError, "Model type not supported" unless mongoid_document?
      fail SpecificationError, "Cannot clone embedded documents" if mongoid_embedded_document?
    end

    def mongoid_document?
      defined?(Mongoid) && model < Mongoid::Document
    end

    def mongoid_embedded_document?
      mongoid_document? && model.embedded?
    end
  end
end

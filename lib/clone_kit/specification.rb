# frozen_string_literal: true

require "clone_kit/emitters/empty"
require "clone_kit/cloners/no_op"
require "clone_kit/id_generators/uuid"

module CloneKit
  class SpecificationError < StandardError; end

  class Specification
    attr_accessor :model,
                  :emitter,
                  :cloner,
                  :dependencies,
                  :after_operation_block,
                  :id_generator

    EMPTY_EMITTER = Emitters::Empty.new
    NO_OP_CLONER = Cloners::NoOp.new
    UUID_GENERATOR = IdGenerators::Uuid.new

    def initialize(model, &block)
      self.model = model
      self.emitter = EMPTY_EMITTER
      self.cloner = NO_OP_CLONER
      self.dependencies = []
      self.after_operation_block = -> (_op) {}
      self.id_generator = UUID_GENERATOR

      configure

      validate!

      model.instance_exec(self, &block)
      cloner.id_generator = id_generator
      CloneKit.add_specification(self)
    end

    def after_operation(&block)
      self.after_operation_block = block
    end

    protected

    def configure

    end

    def validate!

    end
  end
end

# frozen_string_literal: true

require "clone_kit/specification"
require "clone_kit/id_generators/uuid"

module CloneKit
  class ActiveRecordSpecification < Specification
    attr_writer :id_generator

    protected

    def configure
      self.id_generator = IdGenerators::Uuid.new
    end

    def validate!
      fail SpecificationError, "Model type not supported" unless active_record_document?
    end

    def active_record_document?
      defined?(ActiveRecord) && model < ActiveRecord::Base
    end
  end
end

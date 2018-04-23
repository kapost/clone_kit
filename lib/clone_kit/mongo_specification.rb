# frozen_string_literal: true

require "clone_kit/specification"
require "clone_kit/id_generators/bson"

module CloneKit
  class MongoSpecification < Specification
    attr_writer :id_generator

    protected

    def configure
      self.id_generator = IdGenerators::Bson
    end

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

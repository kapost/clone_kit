# frozen_string_literal: true
require File.expand_path(
          "../../lib/clone_kit/cloners/mongoid_ruleset_cloner",
          File.dirname(__FILE__))

require File.expand_path(
          "../../lib/clone_kit/emitters/base_mongoid_emitter",
          File.dirname(__FILE__))

class EmbeddedExampleDoc
  include Mongoid::Document

  field :color, type: String

  embedded_in :example_doc
end

class AnotherEmbeddedExampleDoc
  include Mongoid::Document

  field :color, type: String

  embedded_in :example_doc
end

class ExampleDoc
  include Mongoid::Document

  field :name, type: String
  field :icon, type: String
  field :enabled, type: Boolean

  embeds_many :embedded_example_docs
  embeds_one :another_embedded_example_doc

  validates :name, presence: true

  CloneKit::Specification.new(self) do |spec|
    spec.cloner = CloneKit::Cloners::MongoidRulesetCloner.new(self)
    spec.emitter = CloneKit::Emitters::BaseMongoidEmitter.new(self)
  end
end

# frozen_string_literal: true

require "clone_kit/cloners/mongoid_ruleset_cloner"

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
end

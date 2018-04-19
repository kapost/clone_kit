# frozen_string_literal: true
require_relative "example_doc"

require File.expand_path(
          "../../lib/clone_kit/cloners/active_record_ruleset_cloner",
          File.dirname(__FILE__))

require File.expand_path(
          "../../lib/clone_kit/emitters/base_active_record_emitter",
          File.dirname(__FILE__))

class ArWithMongoidDeps < ActiveRecord::Base
  validates :name, presence: true

  CloneKit::Specification.new(self) do |spec|
    spec.dependencies = [::ExampleDoc]
    spec.cloner = CloneKit::Cloners::ActiveRecordRulesetCloner.new(self)
    spec.emitter = CloneKit::Emitters::BaseActiveRecordEmitter.new(self)
  end
end

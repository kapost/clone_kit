# frozen_string_literal: true

require_relative "example_doc_mongoid"
require "clone_kit/rules/safe_remap"
require "clone_kit/cloners/active_record_ruleset_cloner"

class ArWithMongoidDeps < ActiveRecord::Base
  validates :name, presence: true
end

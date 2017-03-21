# frozen_string_literal: true

require "clone_kit/version"
require "clone_kit/graph"
require "clone_kit/specification"
require "clone_kit/operation"
require "clone_kit/shared_id_map"
require "clone_kit/rule"

require "active_support/core_ext/array/wrap"
require "active_support/core_ext/object/blank"

module CloneKit
  def self.graph
    @graph ||= CloneKit::Graph.new
  end

  def self.load_rails_models!
    Rails.application.eager_load! if defined?(Rails) && !defined?(@eager_loaded_once)
    @eager_loaded_once = true
  end

  def self.spec
    @spec ||= {}
  end

  def self.add_specification(specification)
    spec[specification.model.name] = specification
    refresh_specification(specification)
  end

  def self.refresh_specification(specification)
    graph.add_vertex(specification.model.name, *specification.dependencies)
  end

  def self.cloneable_models(already_cloned)
    result = []
    graph.nodes.each do |model_name, deps|
      next if already_cloned.include?(model_name)
      next unless deps.all? { |dep| already_cloned.include?(dep) }

      result << model_name
    end
    result
  end
end

# frozen_string_literal: true

require "tsort"

module CloneKit
  class Graph
    include TSort

    def initialize
      @vertices = {}
    end

    def nodes
      tsort
      @vertices
    end

    def include?(vertex)
      @vertices.key?(vertex)
    end

    alias topological_sort tsort

    def tsort_each_node(&block)
      @vertices.each_key(&block)
    end

    def tsort_each_child(node, &block)
      @vertices[node].each(&block)
    end

    def add_vertex(vertex, *neighbors)
      existing = @vertices[vertex]

      @vertices[vertex.to_s] = if existing.nil?
                                 Array(neighbors).uniq
                               else
                                 (@vertices[vertex.to_s] + Array(neighbors)).uniq
                               end

      neighbors.each { |n| add_vertex(n) }
    end
  end
end

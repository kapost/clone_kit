# frozen_string_literal: true

require "spec_helper"

RSpec.describe CloneKit::Graph do
  before do
    subject.add_vertex("Post", "PostType", "WorkflowItem")
  end

  describe "#add_vertex" do
    it "creates nodes for each vertex/neighbor" do
      expect(subject.nodes.size).to eql 3
    end

    it "appends duplicate members" do
      subject.add_vertex("Post", "Comment")
      expect(subject.nodes["Post"]).to eql %w[PostType WorkflowItem Comment]
    end
  end

  describe "#topological_sort" do
    before do
      subject.add_vertex("PostType", "newsrooms")
    end

    it "sorts in topological order" do
      expect(subject.topological_sort).to eql %w[newsrooms PostType WorkflowItem Post]
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CloneKit do
  it "has a version number" do
    expect(CloneKit::VERSION).not_to be nil
  end

  subject { described_class }

  class ExampleA
    include Mongoid::Document
  end

  class ExampleB
    include Mongoid::Document
  end

  class ExampleC
    include Mongoid::Document
  end

  before do
    CloneKit::MongoSpecification.new(ExampleA) do |spec|
      spec.dependencies = ["ExampleB"]
    end

    CloneKit::MongoSpecification.new(ExampleB) do |spec|
      spec.dependencies = ["ExampleC"]
    end

    CloneKit::MongoSpecification.new(ExampleC) do |spec|
      spec.dependencies = []
    end
  end

  describe "Specification" do
    context "given a mongoid document" do
      class NonMongoidExample; end

      class NotAnActiveRecordDoc; end

      it "raises unless it's a Mongoid model" do
        expect {
          CloneKit::MongoSpecification.new(NonMongoidExample) { |_| }
        }.to raise_error(CloneKit::SpecificationError, "Model type not supported")
      end
    end

    context "given an ActiveRecord document" do
      it "raises unless it's an ActiveRecord document" do
        expect {
          CloneKit::ActiveRecordSpecification.new(NotAnActiveRecordDoc) { |_| }
        }.to raise_error(CloneKit::SpecificationError, "Model type not supported")
      end
    end

    it "adds to graph" do
      expect(subject.graph.include?("ExampleA")).to be true
    end

    it "adds to spec" do
      expect(subject.spec.key?("ExampleA")).to be true
    end
  end

  describe ".cloneable_models" do
    it "with no models cloned, only ExampleC is cloneable" do
      expect(subject.cloneable_models([])).to eql ["ExampleC"]
    end

    it "with ExampleC cloned, only ExampleB is cloneable" do
      expect(subject.cloneable_models(["ExampleC"])).to eql ["ExampleB"]
    end

    it "with ExampleC and ExampleB cloned, only ExampleA is cloneable" do
      expect(subject.cloneable_models(%w[ExampleC ExampleB])).to eql ["ExampleA"]
    end
  end
end

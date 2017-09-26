# frozen_string_literal: true

require "spec_helper"
require "clone_kit/shared_id_map"
require "clone_kit/id_generators/bson"

RSpec.describe CloneKit::SharedIdMap do
  subject { described_class.new(ns, id_generator) }
  let(:ns) { "unique-123" }
  let(:id_generator) { CloneKit::IdGenerators::Bson.new }

  let(:old_id) { id_generator.next }
  let(:new_id) { id_generator.next }

  before do
    subject.insert(MergableExampleDoc, old_id, new_id)
  end

  describe "#mapping and #insert" do
    it "retrieves an entire mapping for a model" do
      expect(subject.mapping(MergableExampleDoc)).to eql(old_id.to_s => new_id.to_s)
    end

    it "works with strings" do
      expect(subject.mapping("MergableExampleDoc")).to eql(old_id.to_s => new_id.to_s)
    end
  end

  describe "#lookup" do
    it "retrieves new ids based on old ids" do
      expect(subject.lookup(MergableExampleDoc, old_id)).to eql(new_id)
    end
  end

  describe "#insert_many" do
    before do
      subject.insert_many(
        ExampleDoc,
        Hash[
          [
            [id_generator.next, id_generator.next],
            [id_generator.next, id_generator.next],
            [id_generator.next, id_generator.next]
          ]
        ])
    end

    it "stores hash" do
      expect(subject.mapping(ExampleDoc)).to have(3).items
    end
  end
end

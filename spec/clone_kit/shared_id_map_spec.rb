# frozen_string_literal: true

require "spec_helper"
require "clone_kit/shared_id_map"

RSpec.describe CloneKit::SharedIdMap do
  subject { described_class.new(ns) }
  let(:ns) { "unique-123" }

  let(:old_id) { BSON::ObjectId.new }
  let(:new_id) { BSON::ObjectId.new }

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
    def new_id
      BSON::ObjectId.new
    end
    before do
      subject.insert_many(ExampleDoc, Hash[[[new_id, new_id], [new_id, new_id], [new_id, new_id]]])
    end

    it "stores hash" do
      expect(subject.mapping(ExampleDoc)).to have(3).items
    end
  end
end

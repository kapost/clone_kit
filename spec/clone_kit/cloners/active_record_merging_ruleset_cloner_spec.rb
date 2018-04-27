# frozen_string_literal: true

require "spec_helper"
require "clone_kit/cloners/active_record_merging_ruleset_cloner"
require "clone_kit/id_generators/uuid"

RSpec.describe CloneKit::Cloners::ActiveRecordMergingRulesetCloner do
  subject { described_class.new(ExampleActiveRecordDoc) }

  let(:outlet_double) { double("EventOutlet", warn: true, error: true) }

  let(:operation) { CloneKit::Operation.new(event_outlet: outlet_double) }
  let(:name_1) { "One" }
  let(:name_2) { "Two" }
  let(:name_3) { "Three" }

  let!(:existing_ids) do
    [
      ExampleActiveRecordDoc.create!(name: name_1),
      ExampleActiveRecordDoc.create!(name: name_2),
      ExampleActiveRecordDoc.create!(name: name_3)
    ].map(&:id)
  end

  let(:shared_id_map) { CloneKit::SharedIdMap.new(operation.id) }

  def clone
    subject.clone_ids(existing_ids, operation)
  end

  context "given mergeable fields" do
    let(:name_2) { "One" }

    it "clones documents by merging" do
      expect {
        clone
      }.to change(ExampleActiveRecordDoc, :count).by(2)
    end

    it "stores id map correctly" do
      result = clone

      expect(shared_id_map.mapping("ExampleActiveRecordDoc"))
        .to have(3).items
        .and eql(
          existing_ids[0] => result[0]["id"],
          existing_ids[1] => result[0]["id"],
          existing_ids[2] => result[1]["id"]
        )
    end

    it "re-ids documents" do
      expect(clone.map { |r| r["id"] }).to_not match_array(existing_ids)
    end
  end

  context "given non-mergeable fields" do
    it "clones documents without merging" do
      expect {
        clone
      }.to change(ExampleActiveRecordDoc, :count).by(3)
    end

    it "stores id map correctly" do
      result = clone

      expect(shared_id_map.mapping("ExampleActiveRecordDoc"))
        .to have(3).items
        .and eql(
          existing_ids[0] => result[0]["id"],
          existing_ids[1] => result[1]["id"],
          existing_ids[2] => result[2]["id"]
        )
    end

    it "re-ids documents" do
      expect(clone.map { |r| r["id"] }).to_not match_array(existing_ids)
    end
  end
end

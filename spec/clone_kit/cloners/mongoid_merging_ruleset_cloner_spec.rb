# frozen_string_literal: true

require "spec_helper"
require "clone_kit/cloners/mongoid_merging_ruleset_cloner"
require "clone_kit/id_generators/bson"

RSpec.describe CloneKit::Cloners::MongoidMergingRulesetCloner do
  let(:existing_ids) do
    [
      ExampleDoc.create!(name: "Merge Me"),
      ExampleDoc.create!(name: "Merge Me", icon: "vader"),
      ExampleDoc.create!(name: "Vader", icon: "vader")
    ].map(&:id)
  end

  let(:operation) { CloneKit::Operation.new }

  subject { described_class.new(ExampleDoc) }

  let(:run) { subject.clone_ids(existing_ids, operation) }

  describe "#clone_ids" do
    it "merges 3 records into 2" do
      existing_ids
      expect { run }.to change(ExampleDoc, :count).from(3).to(5)
    end

    it "merges by name by default" do
      run
      expect(ExampleDoc.all.order_by([[:_id, -1]]).limit(2).pluck(:name)).to match_array(["Merge Me", "Vader"])
    end

    it "maps old ids to new ones" do
      run
      expect(CloneKit::SharedIdMap.new(operation.id).mapping("ExampleDoc").keys).to have(3).items.and \
        match_array(existing_ids)
    end

    context "when merging by another field" do
      subject { described_class.new(ExampleDoc, merge_fields: ["icon"]) }

      it "merges using that field" do
        run
        expect(ExampleDoc.all.order_by([[:_id, -1]]).limit(2).pluck(:icon)).to match_array([nil, "vader"])
      end
    end
  end
end

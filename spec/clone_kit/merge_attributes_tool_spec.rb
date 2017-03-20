# frozen_string_literal: true

require "spec_helper"
require "clone_kit/merge_attributes_tool"

RSpec.describe CloneKit::MergeAttributesTool do
  subject { described_class.new(records) }

  let(:records) { [MergableExampleDoc.new.as_document, MergableExampleDoc.new.as_document] }
  let(:target) { MergableExampleDoc.new.as_document }

  describe "#hashes" do
    let(:stage_id) { BSON::ObjectId.new }
    let(:persona_id) { BSON::ObjectId.new }
    let(:other_stage_id) { BSON::ObjectId.new }
    let(:other_persona_id) { BSON::ObjectId.new }

    before do
      records[0]["weird_hash"] = {
        "0" => {
          persona_id.to_s => { stage_id.to_s => "Surprise" }
        }
      }

      records[1]["weird_hash"] = {
        "0" => {
          persona_id.to_s => { other_stage_id.to_s => "Deep" },
          other_persona_id.to_s => { other_stage_id.to_s => "You Found Me" }
        }
      }
    end

    it "deeply merges two hashes" do
      subject.hashes(target, "weird_hash")
      expect(target["weird_hash"]).to eql(
        "0" => {
          persona_id.to_s => {
            stage_id.to_s => "Surprise",
            other_stage_id.to_s => "Deep"
          },
          other_persona_id.to_s => {
            other_stage_id.to_s => "You Found Me"
          }
        }
      )
    end
  end

  describe "#arrays" do
    before do
      records[0]["list"] = ["example.com"]
      records[1]["list"] = ["zombo.com", "example.com"]
    end

    it "merges and uniquifies arrays" do
      subject.arrays(target, "list")
      expect(target["list"]).to match_array ["example.com", "zombo.com"]
    end
  end

  describe "#merge_cluster" do
    before do
      records[0]["enabled"] = true
      records[0]["other_thing_enabled"] = true

      records[1]["enabled"] = false
      records[1]["other_thing_enabled"] = false
    end

    let(:target) { MergableExampleDoc.new(other_thing_enabled: false, enabled: false).as_document }

    it "copies attributes from first matching record" do
      expect {
        subject.cluster(target, "enabled", "other_thing_enabled") do |test|
          test["enabled"]
        end
      }.to change { [target["enabled"], target["other_thing_enabled"]] }.from([false, false]).to([true, true])
    end
  end

  describe "#last" do
    before do
      records[0]["enabled"] = true
      records[1]["enabled"] = false
    end

    let(:target) { MergableExampleDoc.new(enabled: true).as_document }

    it "uses the value from the last record" do
      expect { subject.last(target, "enabled") }.to change { target["enabled"] }.to(false)
    end
  end

  describe "#any" do
    before do
      records[0]["list"] = %w[admin editor]
      records[1]["list"] = []

      records[0]["enabled"] = false
      records[1]["enabled"] = true
    end

    let(:target) { MergableExampleDoc.new(list: [], enabled: false).as_document }

    it "uses any non-blank values" do
      expect { subject.any(target, "list", "enabled") }.to change {
        [target["list"], target["enabled"]]
      }.from([%w[], false]).to([%w[admin editor], true])
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "clone_kit/cloners/active_record_ruleset_cloner"
require "clone_kit/id_generators/uuid"

RSpec.describe CloneKit::Cloners::ActiveRecordRulesetCloner do
  subject { described_class.new(ExampleActiveRecordDoc) }

  let(:outlet_double) { double("EventOutlet", warn: true, error: true) }

  let(:operation) { CloneKit::Operation.new(event_outlet: outlet_double) }

  let!(:existing_ids) do
    [
      ExampleActiveRecordDoc.create!(name: "Marge"),
      ExampleActiveRecordDoc.create!(name: "Large", icon: "vader"),
      ExampleActiveRecordDoc.create!(name: "Vader", icon: "vader")
    ].map(&:id)
  end

  let(:shared_id_map) { CloneKit::SharedIdMap.new(operation.id) }

  def clone
    subject.clone_ids(existing_ids, operation)
  end

  it "clones documents" do
    expect {
      clone
    }.to change(ExampleActiveRecordDoc, :count).by(3)
  end

  it "re-ids documents" do
    expect(clone.map { |r| r["id"] }).to_not match_array(existing_ids)
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

  context "when invalid data is already persisted" do
    before do
      id = existing_ids[0]
      ActiveRecord::Base
        .connection
        .execute("UPDATE example_active_record_docs SET name = NULL WHERE id ='#{id}';")
    end

    it "performs model validations" do
      clone
      expected_message =
        /ExampleActiveRecordDoc [a-f0-9\-]{36} failed model validation and was not cloned: Name can't be blank/
      expect(outlet_double).to have_received(:error).with(expected_message)
    end
  end
end

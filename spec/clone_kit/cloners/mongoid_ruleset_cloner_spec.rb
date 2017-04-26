# frozen_string_literal: true

require "spec_helper"
require "clone_kit/cloners/mongoid_ruleset_cloner"

RSpec.describe CloneKit::Cloners::MongoidRulesetCloner do
  subject { described_class.new(ExampleDoc) }

  let(:another_doc) { AnotherEmbeddedExampleDoc.new(color: "yellow") }
  let(:embedded_doc) { EmbeddedExampleDoc.new(color: "red") }
  let(:outlet_double) { double("EventOutlet", warn: true, error: true) }

  let(:operation) { CloneKit::Operation.new(event_outlet: outlet_double) }

  let!(:existing_ids) do
    [
      ExampleDoc.create!(name: "Marge"),
      ExampleDoc.create!(name: "Large", icon: "vader", another_embedded_example_doc: another_doc),
      ExampleDoc.create!(name: "Vader", icon: "vader", embedded_example_docs: [embedded_doc])
    ].map(&:id)
  end

  let(:shared_id_map) { CloneKit::SharedIdMap.new(operation.id) }

  def clone
    subject.clone_ids(existing_ids, operation)
  end

  it "clones documents" do
    expect {
      clone
    }.to change(ExampleDoc, :count).by(3)
  end

  it "re-ids documents" do
    expect(clone.map { |r| r["_id"] }).to_not match_array(existing_ids)
  end

  it "clones and re-ids embedded documents" do
    result = clone
    expect(result[2]["embedded_example_docs"][0]["_id"]).to_not eql(embedded_doc.id)
  end

  it "doesn't assign nil to empty embedded collections" do
    result = clone
    expect(result[0]["embedded_example_docs"]).to have(0).items
  end

  it "stores id map correctly" do
    result = clone
    expect(shared_id_map.mapping("ExampleDoc")).to have(3).items.and \
      eql(
        existing_ids[0].to_s => result[0]["_id"].to_s,
        existing_ids[1].to_s => result[1]["_id"].to_s,
        existing_ids[2].to_s => result[2]["_id"].to_s
      )
  end

  it "stores embedded id map correctly" do
    result = clone
    existing_embedded_id = ExampleDoc.find(existing_ids[2]).embedded_example_docs[0].id
    new_embedded_id = result[2]["embedded_example_docs"][0]["_id"].to_s

    expect(shared_id_map.mapping("EmbeddedExampleDoc")).to have(1).item.and \
      eql(
        existing_embedded_id.to_s => new_embedded_id.to_s
      )
  end

  context "when invalid data is already persisted" do
    before do
      ExampleDoc.find(existing_ids[0]).set(name: "")
    end

    it "performs model validations" do
      clone
      expected_message = /ExampleDoc [a-f0-9]{24} failed model validation and was not cloned: Name can't be blank/
      expect(outlet_double).to have_received(:error).with(expected_message)
    end
  end
end

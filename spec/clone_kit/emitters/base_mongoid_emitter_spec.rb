# frozen_string_literal: true

require "spec_helper"

RSpec.describe CloneKit::Emitters::BaseMongoidEmitter do
  subject { described_class.new(ExampleDoc) }

  describe "#scope" do
    let(:query) { subject.scope }

    it "returns a Mongoid::Criteria selector" do
      expect(query).to be_a Mongoid::Criteria
    end

    it "returns :all by default" do
      expect(query.selector).to be_empty
    end
  end

  describe "#emit_all" do
    context "given a single record exists" do
      let!(:example_doc) do
        ExampleDoc.create!(name: "Vader", icon: "vader")
      end

      let(:all) { subject.emit_all }

      it "returns it" do
        expect(all).to match_array(example_doc)
      end
    end
  end
end

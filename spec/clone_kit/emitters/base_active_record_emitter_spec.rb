# frozen_string_literal: true

require "spec_helper"

RSpec.describe CloneKit::Emitters::BaseActiveRecordEmitter do
  subject { described_class.new(ExampleActiveRecordDoc) }

  describe "#scope" do
    let(:query) { subject.scope }

    it "returns the resulting ActiveRecord query" do
      expect(query).to eq []
    end
  end

  describe "#emit_all" do
    context "given a single record exists" do
      let!(:example_active_record_doc) do
        ExampleActiveRecordDoc.create!(name: "Vader")
      end

      let(:all) { subject.emit_all }

      it "returns it" do
        expect(all).to match_array(example_active_record_doc)
      end
    end
  end
end

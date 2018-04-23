require "spec_helper"

RSpec.describe CloneKit::Operation do
  let(:outlet_double) { double("EventOutlet", warn: true, error: true) }

  subject { described_class.new(event_outlet: outlet_double) }

  context "when it operates on ActiveRecord models" do
    before do
      CloneKit::Specification.new(ExampleDoc) do |spec|
        spec.cloner = CloneKit::Cloners::MongoidRulesetCloner.new(self)
        spec.emitter = CloneKit::Emitters::BaseMongoidEmitter.new(self)
      end

      CloneKit::Specification.new(ArWithMongoidDeps) do |spec|
        spec.dependencies = ["ExampleDoc"]
        spec.cloner = CloneKit::Cloners::ActiveRecordRulesetCloner
          .new(self, rules: [
                 CloneKit::Rules::SafeRemap.new(
                   self,
                   "ExampleDoc" => ["example_doc_id"]
                 )
               ])
        spec.emitter = CloneKit::Emitters::BaseActiveRecordEmitter.new(self)
      end
    end

    context "and there are dependencies on mongoid records" do
      let!(:example_mongoid_doc_1) do
        ExampleDoc.create!(name: "one")
      end

      let!(:example_mongoid_doc_2) do
        ExampleDoc.create!(name: "two")
      end

      let(:example_mongoid_doc_1_id) { example_mongoid_doc_1.id.to_s }
      let(:example_mongoid_doc_2_id) { example_mongoid_doc_2.id.to_s }

      let!(:active_record_1) do
        ArWithMongoidDeps.create!(name: "one", example_doc_id: example_mongoid_doc_1.id.to_s)
      end

      let!(:active_record_2) do
        ArWithMongoidDeps.create!(name: "two", example_doc_id: example_mongoid_doc_2.id.to_s)
      end

      it "the original records are cloned" do
        expect { subject.process }.to change(ArWithMongoidDeps, :count).by 2
      end

      it "the dependencies are cloned" do
        expect { subject.process }.to change(ExampleDoc, :count).by 2
      end

      context "and there is a remapping rule present" do
        let(:a_uuid) { /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }

        let(:cloned_mongoid_association_ids_from_active_record_models) do
          ArWithMongoidDeps.pluck(:example_doc_id) -
            [example_mongoid_doc_1_id, example_mongoid_doc_2_id]
        end

        let(:cloned_example_doc_ids) do
          (ExampleDoc.all.to_a - [example_mongoid_doc_1, example_mongoid_doc_2])
            .map { |doc| doc.id.to_s }
        end

        after do
          expect(cloned_example_doc_ids.length).to eq 2
          expect { cloned_example_doc_ids.all? { |id| BSON::ObjectId.from_string(id) } }
           .not_to raise_error, -> { cloned_example_doc_ids }

          expect(ArWithMongoidDeps.pluck(:id).all? do |id|
                   id.match a_uuid
                 end).to be_truthy
        end

        it "remaps the ids" do
          subject.process
          expect(cloned_mongoid_association_ids_from_active_record_models)
            .to match_array(cloned_example_doc_ids)
        end
      end
    end
  end
end

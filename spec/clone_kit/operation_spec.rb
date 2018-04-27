require "spec_helper"

RSpec.describe CloneKit::Operation do
  let(:outlet_double) { double("EventOutlet", warn: true, error: true) }

  subject { described_class.new(event_outlet: outlet_double) }

  context "when it operates on ActiveRecord models" do
    before do
      CloneKit::Specification.new(ExampleDoc) do |spec|
        spec.cloner = CloneKit::Cloners::MongoidRulesetCloner.new(self)
        spec.emitter = MongoidEmitter.new(self)
      end

      CloneKit::Specification.new(ArWithMongoidDeps) do |spec|
        spec.dependencies = ["ExampleDoc"]
        spec.cloner = CloneKit::Cloners::ActiveRecordRulesetCloner.new(
          self,
          rules: [
            CloneKit::Rules::SafeRemap.new(
              self,
              "ExampleDoc" => ["example_doc_id"],
              id_generator: CloneKit::IdGenerators::Bson
            )
          ]
        )
        spec.emitter = ActiveRecordEmitter.new(self)
      end
    end

    context "and there are dependencies on mongoid records" do
      let!(:mongoid_doc_1) { ExampleDoc.create!(name: "one") }
      let!(:mongoid_doc_2) { ExampleDoc.create!(name: "two") }
      let!(:active_record_doc_1) { ArWithMongoidDeps.create!(name: "one", example_doc_id: mongoid_doc_1.id.to_s) }
      let!(:active_record_doc_2) { ArWithMongoidDeps.create!(name: "two", example_doc_id: mongoid_doc_2.id.to_s) }

      let(:mongoid_ids) { [mongoid_doc_1.id, mongoid_doc_2.id] }
      let(:active_record_ids) { [active_record_doc_1.id, active_record_doc_2.id] }
      let(:cloned_mongoid_doc_ids) { ExampleDoc.where(id: { "$nin" => mongoid_ids }).pluck(:id) }
      let(:cloned_active_record_doc_ids) { ArWithMongoidDeps.where.not(id: active_record_ids).pluck(:id) }

      it "the original records are cloned" do
        expect { subject.process }.to change(ArWithMongoidDeps, :count).by(2)
      end

      it "the dependencies are cloned" do
        expect { subject.process }.to change(ExampleDoc, :count).by(2)
      end

      context "when a given rule is passed an id_generator" do
        def stub_generator(generator, times)
          ids = times.times.map { generator.next }
          call_count = 0

          allow(generator).to receive(:next) do
            raise "no more stubbed values" if call_count >= ids.size

            call_count += 1
            ids[call_count - 1]
          end

          ids
        end

        let(:count) { 2 }
        let!(:uuids) { stub_generator(CloneKit::IdGenerators::Uuid, count) }
        let!(:bson_ids) { stub_generator(CloneKit::IdGenerators::Bson, count) }

        it "it generates IDs using the provided generator" do
          subject.process

          expect(cloned_active_record_doc_ids).to match_array(uuids)
          expect(cloned_mongoid_doc_ids).to match_array(bson_ids)
        end
      end

      context "when no optional id_generator args are passed to a rule" do
        before do
          CloneKit::Specification.new(ArWithMongoidDeps) do |spec|
            spec.dependencies = ["ExampleDoc"]
            spec.cloner = CloneKit::Cloners::ActiveRecordRulesetCloner.new(
              self,
              rules: [
                CloneKit::Rules::SafeRemap.new(
                  self,
                  "ExampleDoc" => ["example_doc_id"]
                )
              ]
            )
            spec.emitter = ActiveRecordEmitter.new(self)
          end
        end

        it "get's it's generator from the cloner" do
          expect(CloneKit::IdGenerators::Uuid).to receive(:from_string).twice
          expect(CloneKit::IdGenerators::Bson).to_not receive(:from_string)
          subject.process
        end
      end

      context "and there is a remapping rule present" do
        let(:cloned_mongoid_association_ids_from_active_record_models) do
          ArWithMongoidDeps.pluck(:example_doc_id) - mongoid_ids.map(&:to_s)
        end

        it "remaps the ids" do
          subject.process
          expect(cloned_mongoid_association_ids_from_active_record_models).to match_array(cloned_mongoid_doc_ids)
        end

        it "creates the correct records" do
          subject.process
          expect(cloned_mongoid_doc_ids).to have(2).items.and all(be_bson_id)
          expect(cloned_active_record_doc_ids).to have(2).items.and all(be_uuid)
        end
      end
    end
  end
end

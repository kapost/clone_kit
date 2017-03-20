# frozen_string_literal: true

module CloneKit
  module Rules
    class ReIdEmbeddedMongoidModels < CloneKit::Rule
      def initialize(model_klass)
        self.model_klass = model_klass
      end

      def fix(_old_id, attributes)
        mapping = {}

        model_klass.embedded_relations.each do |name, _metadata|
          embedded_klass_name = name.classify
          mapping[embedded_klass_name] = {}
          Array.wrap(attributes[name]).each do |item|
            new_id = BSON::ObjectId.new
            mapping[embedded_klass_name][item["_id"]] = new_id
            item["_id"] = new_id
          end
        end

        mapping.each do |embedded_klass_name, map|
          shared_id_map.insert_many(embedded_klass_name, map)
        end
      end

      private

      attr_accessor :model_klass
    end
  end
end

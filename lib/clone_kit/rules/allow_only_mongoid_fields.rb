# frozen_string_literal: true

module CloneKit
  module Rules
    #
    # The purpose of this rule is to only include attributes that are
    # presently defined on the model (and its embedded models)

    class AllowOnlyMongoidFields < CloneKit::Rule
      def initialize(model_klass)
        self.model_klass = model_klass
      end

      def fix(_old_id, attributes)
        slice_allowed!(polymorphic_class(model_klass.to_s, attributes), attributes)
      end

      private

      attr_accessor :model_klass

      def slice_allowed!(klass, attributes)
        return if attributes.nil?

        attributes.slice!(*(klass.attribute_names + klass.embedded_relations.keys))

        klass.embedded_relations.each do |name, metadata|
          if metadata.macro == :embeds_many
            Array.wrap(attributes[name]).each do |item|
              slice_allowed!(polymorphic_class(metadata.class_name, item), item)
            end
          elsif !attributes[name].nil?
            slice_allowed!(polymorphic_class(metadata.class_name, attributes[name]), attributes[name])
          end
        end
      end

      def polymorphic_class(class_name, item)
        if item.key?("_type")
          item["_type"]
        else
          class_name
        end.constantize
      end
    end
  end
end

# frozen_string_literal: true

module CloneKit
  module Rules
    # The purpose of this rule is to only include attributes that are presently defined on the model
    class AllowOnlyActiveRecordFields < CloneKit::Rule
      def initialize(model_klass)
        self.model_klass = model_klass
      end

      def fix(_old_id, attributes)
        slice_allowed!(model_klass, attributes)
      end

      private

      attr_accessor :model_klass

      def slice_allowed!(klass, attributes)
        return if attributes.nil?

        attributes.slice!(*klass.attribute_names)
      end
    end
  end
end

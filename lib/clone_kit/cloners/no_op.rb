# frozen_string_literal: true

module CloneKit
  module Cloners
    class NoOp
      attr_writer :id_generator
      def clone_ids(_ids, _operation)
        # NO_OP
      end

      def register_id_generator_with_rules; end
    end
  end
end

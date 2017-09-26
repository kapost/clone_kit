# frozen_string_literal: true

module CloneKit
  module Cloners
    class NoOp
      attr_writer :id_generator
      def clone_ids(_ids, _operation)
        # NO_OP
      end
    end
  end
end

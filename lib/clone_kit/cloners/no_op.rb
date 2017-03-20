# frozen_string_literal: true

module CloneKit
  module Cloners
    class NoOp
      def clone_ids(_ids, _operation)
        # NO_OP
      end
    end
  end
end

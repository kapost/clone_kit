# frozen_string_literal: true

module CloneKit
  module Emitters
    class Empty
      def emit_all(_args)
        []
      end

      def emit_each_range(_args, _page_size = 0)
        # No yields
      end
    end
  end
end

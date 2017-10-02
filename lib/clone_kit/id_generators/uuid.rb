# frozen_string_literal: true

module CloneKit
  module IdGenerators
    class Uuid
      def self.next
        SecureRandom.uuid
      end

      def from_string(val)
        val
      end
    end
  end
end

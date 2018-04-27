# frozen_string_literal: true

module CloneKit
  module IdGenerators
    module Uuid
      def self.next
        SecureRandom.uuid
      end

      def self.from_string(val)
        val
      end
    end
  end
end

# frozen_string_literal: true

module CloneKit
  module IdGenerators
    class Bson
      def self.next
        BSON::ObjectId.new
      end

      def self.from_string(val)
        BSON::ObjectId.from_string(val)
      rescue BSON::ObjectId::Invalid => error
        raise InvalidId, error
      end
    end
  end
end

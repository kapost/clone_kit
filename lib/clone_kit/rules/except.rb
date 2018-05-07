# frozen_string_literal: true

module CloneKit
  module Rules
    #
    # Removes attributes defined by an array of keys

    class Except < CloneKit::Rule
      def initialize(*excepted_attributes)
        self.excepted_attributes = excepted_attributes
      end

      def fix(_old_id, attributes)
        excepted_attributes.each do |key|
          attributes.delete(key)
        end
      end

      private

      attr_accessor :excepted_attributes
    end
  end
end

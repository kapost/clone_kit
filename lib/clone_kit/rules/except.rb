# frozen_string_literal: true

module CloneKit
  module Rules
    class Except < CloneKit::Rule
      def initialize(*attributes)
        self.except_attributes = attributes
      end

      def fix(_old_id, attributes)
        except_attributes.each do |key|
          attributes.delete(key)
        end
      end

      private

      attr_accessor :except_attributes
    end
  end
end

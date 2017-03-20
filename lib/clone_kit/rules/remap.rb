# frozen_string_literal: true

module CloneKit
  module Rules
    class Remap < CloneKit::Rule
      def initialize(remap_hash = {})
        self.remap_hash = remap_hash
      end

      def fix(_old_id, attributes)
        remap_hash.each do |klass, remap_attributes|
          Array.wrap(remap_attributes).each do |att|
            next unless attributes.key?(att)

            if attributes[att].is_a?(Array)
              attributes[att] = attributes[att].compact.map { |id|
                remap(klass, id)
              }.compact
            elsif !attributes[att].nil?
              attributes[att] = remap(klass, attributes[att])
            end
          end
        end
      end

      protected

      def remap(klass, old_id)
        shared_id_map.lookup(klass, old_id)
      end

      private

      attr_accessor :remap_hash
    end
  end
end

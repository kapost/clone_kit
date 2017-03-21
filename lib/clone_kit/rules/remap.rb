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
            next unless try?(attributes, att)

            attributes[att] = if attributes[att].is_a?(Array)
                                attributes[att].map { |id| remap(klass, id) unless id.blank? }.compact
                              else
                                remap(klass, attributes[att])
                              end
          end
        end
      end

      protected

      def remap(klass, old_id)
        shared_id_map.lookup(klass, old_id)
      end

      def try?(attributes, key)
        attributes.key?(key) && !attributes[key].blank?
      end

      private

      attr_accessor :remap_hash
    end
  end
end

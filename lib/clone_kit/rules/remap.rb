# frozen_string_literal: true

module CloneKit
  module Rules
    class Remap < CloneKit::Rule
      def initialize(model_name, remap_hash = {})
        self.remap_hash = remap_hash
        self.model_name = model_name
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
        shared_id_map.lookup(klass, old_id, id_generator: id_generator)
      rescue ArgumentError
        error_event("#{model_name} missing remapped id for #{klass} #{old_id}")
        nil
      end

      def try?(attributes, key)
        attributes.key?(key) && !attributes[key].blank?
      end

      private

      attr_accessor :remap_hash,
                    :model_name
    end
  end
end

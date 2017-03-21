# frozen_string_literal: true

require "clone_kit/rules/remap"

module CloneKit
  module Rules
    class SafeRemap < Remap
      def initialize(model_name, remap_hash = {}, safe_value = nil)
        self.safe_value = safe_value
        super(model_name, remap_hash)
      end

      protected

      def remap(klass, old_id)
        result = shared_id_map.lookup_safe(klass, old_id, safe_value)
        warn_event("#{model_name} missing remapped id for #{klass}/#{old_id}") if result == safe_value
        result
      end

      private

      attr_accessor :safe_value
    end
  end
end

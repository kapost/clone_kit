# frozen_string_literal: true

require "clone_kit/rules/remap"

module CloneKit
  module Rules
    #
    # Operates like Remap, but returns a default value instead of `nil`.
    # When the default is used, the event outlet receives a #warn message.

    class SafeRemap < Remap
      def initialize(model_name, remap_hash = {}, safe_value = nil, id_generator: nil)
        super(model_name, remap_hash, id_generator: id_generator)
        self.safe_value = safe_value
      end

      protected

      def remap(klass, old_id)
        result = shared_id_map
                 .lookup_safe(klass, old_id, safe_value, id_generator: id_generator)
        warn_event("#{model_name} missing remapped id for #{klass}/#{old_id}") if result == safe_value
        result
      end

      private

      attr_accessor :safe_value
    end
  end
end

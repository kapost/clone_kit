# frozen_string_literal: true

module CloneKit
  module Rules
    #
    # Utilizes the SharedIdMap stored in Redis to remap original
    # ids to their new cloned values.
    #
    #   Given an original blog post being cloned:
    #     { title: "Title", author_id: 5 }
    #   And a blog post rule:
    #     Remap.new(BlogPost, "Author" => "author_id")
    #   And an author record that was cloned from => to:
    #     { id: 5, name: "Pat" } => { id: 6, name: "Pat" }
    #   The cloned blog post will show the remapped author id:
    #     { title: "Title", author_id: 6 }
    #
    # When a remapped id is missing, an error is added to the operation.

    class Remap < CloneKit::Rule
      def initialize(model_name, remap_hash = {}, id_generator: nil)
        super(id_generator: id_generator)
        self.remap_hash = remap_hash
        self.model_name = model_name
      end

      def fix(_old_id, attributes)
        remap_hash.each do |klass, remap_attributes|
          Array.wrap(remap_attributes).each do |att|
            next unless try?(attributes, att)

            attributes[att] = if attributes[att].is_a?(Array)
                                attributes[att].map { |id| remap(klass, id) if id.present? }.compact
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
        attributes.key?(key) && attributes[key].present?
      end

      private

      attr_accessor :remap_hash,
                    :model_name
    end
  end
end

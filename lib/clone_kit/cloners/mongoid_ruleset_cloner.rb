# frozen_string_literal: true

require "clone_kit/rules/allow_only_mongoid_fields"
require "clone_kit/decorators/embedded_cloner_decorator"

module CloneKit
  module Cloners
    class MongoidRulesetCloner
      attr_accessor :rules, :id_generator

      def initialize(model_klass, rules: [], id_generator: CloneKit::IdGenerators::Bson)
        self.model_klass = model_klass
        self.rules = [
          CloneKit::Rules::AllowOnlyMongoidFields.new(model_klass)
        ] + rules
        self.id_generator = id_generator
      end

      def clone_ids(ids, operation)
        initialize_cloner(operation)

        map = {}
        result = []

        each_existing_record(ids) do |attributes|
          attributes = clone(attributes)
          result << apply_rules_and_save(map, attributes)
        end

        CloneKit::SharedIdMap.new(operation.id).insert_many(model_klass, map)

        result
      end

      protected

      attr_accessor :model_klass,
                    :current_operation

      def clone(attributes)
        attributes = attributes.deep_dup
        clone_all_embedded_fields(attributes)
        attributes
      end

      def clone_all_embedded_fields(attributes)
        model_klass.embedded_relations.each do |name, metadata|
          attributes[name] = clone_embedded_field(attributes[name], metadata)
        end
      end

      def clone_embedded_field(item, metadata)
        first_item = if item.is_a?(Array)
                       item = item.compact
                       item[0]
                     else
                       item
                     end

        return empty_embedded(metadata) if first_item.nil?

        cloner = MongoidRulesetCloner.new(polymorphic_class(metadata.class_name, first_item), id_generator: id_generator)
        embedded_cloner = CloneKit::Decorators::EmbeddedClonerDecorator.new(cloner, records: Array.wrap(item))

        embedded_attributes = embedded_cloner.clone_embedded(current_operation)

        if metadata.macro == :embeds_many
          embedded_attributes
        else
          embedded_attributes[0]
        end
      end

      def empty_embedded(metadata)
        metadata.macro == :embeds_many ? [] : nil
      end

      def apply_rules_and_save(mapping, attributes)
        new_id = generate_new_id
        old_id = attributes["_id"]
        mapping[attributes["_id"]] = new_id
        attributes["_id"] = new_id

        rules.each do |rule|
          begin
            rule.fix(old_id, attributes)
          rescue StandardError => e
            message = "Unhandled error when applying rule #{rule.class.name} to #{model_klass} #{new_id}: #{e.class}"
            current_operation.error(message)
          end
        end

        save_or_fail(attributes)
        attributes
      end

      def generate_new_id
        id_generator.next
      end

      def save_or_fail(attributes)
        document_klass = model_klass
        document_klass = attributes["_type"].constantize if attributes.key?("_type")

        model_that_we_wont_save = document_klass.new(attributes)

        if model_that_we_wont_save.valid?
          model_klass.collection.insert_one(attributes)
        else
          report_errors(attributes, model_that_we_wont_save)
        end
      end

      def report_errors(attributes, model)
        model_error = model.errors.full_messages.to_sentence
        embedded_errors = collect_embedded_errors(model)
        id = attributes["_id"]

        current_operation.error("#{model_klass} #{id} failed model validation and was not cloned: #{model_error}")

        embedded_errors.each do |e|
          current_operation.error("[#{model_klass} #{id}]: #{e}")
        end
      end

      def collect_embedded_errors(model)
        embedded_documents(model).each_with_object([]) do |doc, accum|
          next if doc.blank? || doc.valid?

          klass = doc.class
          id = doc._id.to_s
          error = doc.errors.full_messages.to_sentence

          accum << "Embedded #{klass} #{id} failed model validation: #{error}"
        end
      end

      def embedded_documents(model)
        model.associations
             .select { |_key, assoc| assoc.embedded? }
             .keys
             .map { |field| model.send(field) }
             .flatten
      end

      def each_existing_record(ids)
        ids.each do |id|
          record = model_klass.collection.find(_id: id).first
          next if record.nil?

          yield record
        end
      end

      def initialize_cloner(operation)
        @current_operation = operation

        rules.each do |rule|
          rule.current_operation = @current_operation
          rule.id_generator = id_generator
        end
      end

      private

      def polymorphic_class(class_name, item)
        if item.key?("_type")
          item["_type"]
        else
          class_name
        end.constantize
      end
    end
  end
end

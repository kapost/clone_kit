# frozen_string_literal: true

require "clone_kit/decorators/embedded_cloner_decorator"

module CloneKit
  module Cloners
    class ActiveRecordRulesetCloner
      attr_accessor :rules, :id_generator

      def initialize(model_klass, rules: [], id_generator: IdGenerators::Uuid)
        self.model_klass = model_klass
        self.rules = rules
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
        attributes.deep_dup
      end

      def apply_rules_and_save(mapping, attributes)
        new_id = generate_new_id
        old_id = attributes["id"]
        mapping[old_id] = new_id
        attributes["id"] = new_id

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
        model_that_we_wont_save = document_klass.new(attributes)
        if model_that_we_wont_save.valid?
          insert(model_that_we_wont_save)
        else
          details = model_that_we_wont_save.errors.full_messages.to_sentence
          id = attributes["id"]
          current_operation.error("#{model_klass} #{id} failed model validation and was not cloned: #{details}")
        end
      end

      def insert(model)
        insert_op = model.class.arel_table.create_insert.tap do |insert_mgr|
          insert_mgr.insert(arel_attributes_with_values_for_create(model))
        end

        connection.execute(insert_op.to_sql)
      end

      def each_existing_record(ids)
        ids.each do |id|
          record = model_klass.find_by(model_klass.primary_key => id).attributes
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

      def connection
        ActiveRecord::Base.connection
      end

      private

      # This method has been deprecated in rails 5.2 (https://github.com/rails/rails/commit/2f45157f2ebbe4f3fa43d3998b459c8eb9ec2b89)
      # Workarounds to this method started to fail other parts of the code base. Hence I am defining it here.
      def arel_attributes_with_values_for_create(model)
        attrs = {}
        arel_table = model.class.arel_table
        attribute_names = model.send(:attributes_for_create, model.attribute_names)

        attribute_names.each do |name|
          attrs[arel_table[name]] = model.send(:_read_attribute, name)
        end

        attrs
      end
    end
  end
end

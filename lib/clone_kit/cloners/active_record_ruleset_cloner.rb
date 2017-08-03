# frozen_string_literal: true

module CloneKit
  module Cloners
    class ActiveRecordRulesetCloner
      attr_accessor :rules

      def initialize(
        model_klass,
        rules: [],
        database_name: database_config.fetch("database")
      )
        self.model_klass = model_klass
        self.rules = rules
        self.connection = PG.connect(dbname: database_name)
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
                    :current_operation,
                    :connection

      def database_config
        return {} unless defined?(Rails)

        Rails.configuration.database_configuration[Rails.env]
      end

      def clone(attributes)
        attributes = attributes.deep_dup
        attributes
      end

      def apply_rules_and_save(mapping, attributes)
        new_id = SecureRandom.uuid
        old_id = attributes["id"]
        mapping[attributes["id"]] = new_id
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
        insert_op = model.class.arel_table.create_insert.tap do |im|
          im.insert(
            model.send(:arel_attributes_with_values_for_create, model.attribute_names)
          )
        end

        connection.exec(insert_op.to_sql)
      end

      def each_existing_record(ids)
        ids.each do |id|
          find_query = "SELECT * FROM #{model_klass.table_name} WHERE Id='#{id}'"
          record = connection.exec(find_query).first
          next if record.nil?

          yield record
        end
      end

      def initialize_cloner(operation)
        @current_operation = operation

        rules.each do |rule|
          rule.current_operation = @current_operation
        end
      end
    end
  end
end

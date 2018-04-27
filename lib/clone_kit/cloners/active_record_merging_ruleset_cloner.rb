# frozen_string_literal: true

require "clone_kit/cloners/active_record_ruleset_cloner"

module CloneKit
  module Cloners
    class ActiveRecordMergingRulesetCloner < ActiveRecordRulesetCloner
      ID = "id"

      def initialize(model_klass, rules: [], merge_fields: ["name"])
        super(model_klass, rules: rules)
        self.merge_fields = merge_fields
      end

      def clone_ids(ids, operation)
        @saved_id_map = {}
        initialize_cloner(operation)
        apply_rules_and_save(find_and_merge_existing_records(ids))
      end

      protected

      # These methods are super simple and should usually be overridden to merge records in a more nuanced fashion

      def compare(first, second)
        merge_fields.all? { |name| first[name] == second[name] }
      end

      def merge(records)
        result = nil
        records.each do |rec|
          result = if result.nil?
                     rec.deep_dup
                   else
                     result.merge(rec)
                   end
        end

        result
      end

      private

      attr_accessor :merge_fields

      def find_and_merge_existing_records(ids, mergeable: Set.new, skip: skip = Set.new)
        all_records = []
        each_existing_record(ids) do |rec|
          all_records << rec
        end

        result = []

        all_records.each_with_index do |record, i|
          next if skip.include?(record[ID])
          mergeable << record

          all_records[i + 1..all_records.length].each do |other_record|
            next unless compare(record, other_record)

            mergeable << other_record
            skip << other_record[ID]
          end

          new_id = generate_new_id
          new_record = if mergeable.length == 1
                          copy = clone(mergeable.first)
                          @saved_id_map[copy[ID]] = new_id
                          copy
                       else
                          merged = merge(mergeable)

                          mergeable.each do |m|
                            @saved_id_map[m[ID]] ||= new_id
                          end
                          merged
                       end

          new_record[ID] = new_id

          result << new_record
        end

        CloneKit::SharedIdMap
          .new(current_operation.id)
          .insert_many(model_klass, @saved_id_map)

        result
      end

      def apply_rules_and_save(records)
        records.each do |attributes|
          id = attributes[ID]
          rules.each do |rule|
            begin
              rule.fix(@saved_id_map.key(id), attributes)
            rescue StandardError => e
              id = attributes[ID]
              message = "Unhandled error when applying rule #{rule.class.name} to #{model_klass} #{id}: #{e.class}"
              current_operation.error(message)
            end
          end

          save_or_fail(attributes)
        end
      end
    end
  end
end

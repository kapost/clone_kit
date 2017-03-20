# frozen_string_literal: true

require "delegate"

module CloneKit
  module Decorators
    class EmbeddedClonerDecorator < SimpleDelegator
      attr_reader :records

      def initialize(cloner, records:)
        @records = records

        cloner.define_singleton_method(:each_existing_record) do |ids, &block|
          records.compact.select { |r| ids.include?(r["_id"]) }.each do |record|
            block.call(record)
          end
        end

        cloner.define_singleton_method(:save_or_fail) do |attributes|
          # NOP
        end

        super(cloner)
      end

      def clone_embedded(operation)
        clone_ids(records.compact.map { |r| r["_id"] }, operation)
      end
    end
  end
end

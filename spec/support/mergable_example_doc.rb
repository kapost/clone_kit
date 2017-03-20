# frozen_string_literal: true

class MergableExampleDoc
  include Mongoid::Document

  field :name, type: String
  field :icon, type: String
  field :enabled, type: Boolean
  field :other_thing_enabled, type: Boolean
  field :weird_hash, type: Hash
  field :list, type: Array
end

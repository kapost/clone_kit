# frozen_string_literal: true

class ExampleActiveRecordDoc < ActiveRecord::Base
  validates :name, presence: true
end

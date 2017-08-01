class ExampleActiveRecordDoc < ActiveRecord::Base
  validates :name, presence: true
end

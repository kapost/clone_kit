# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  enable_extension "uuid-ossp"

  create_table :example_active_record_docs, id: :uuid, force: true do |t|
    t.string :name
    t.string :icon
    t.boolean :enabled
    t.timestamps
  end

  create_table :ar_with_mongoid_deps, id: :uuid, force: true do |t|
    t.string :name
    t.string :example_doc_id
  end
end

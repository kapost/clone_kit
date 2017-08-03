class CreateExampleActiveRecordDocs < ActiveRecord::Migration
  def change
    enable_extension "uuid-ossp"

    create_table :example_active_record_docs, id: :uuid do |t|
      t.string :name
      t.string :icon
      t.boolean :enabled
    end
  end
end

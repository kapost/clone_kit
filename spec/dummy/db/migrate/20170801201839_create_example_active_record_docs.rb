class CreateExampleActiveRecordDocs < ActiveRecord::Migration
  def change
    create_table :example_active_record_docs do |t|
      t.string :name
      t.string :icon
      t.boolean :enabled
    end
  end
end

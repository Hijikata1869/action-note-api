class CreateReadingNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_notes do |t|
      t.text :content, null: false
      t.references :book, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end

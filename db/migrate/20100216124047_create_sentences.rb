class CreateSentences < ActiveRecord::Migration
  def self.up
    create_table :sentences do |t|
      t.references :process_document_element
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :sentences
  end
end

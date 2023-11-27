class CreateAccreditationTypeKeywords < ActiveRecord::Migration[6.1]
  def change
    create_table :accreditation_type_keywords do |t|
      t.string :accreditation_type
      t.string :keyword_match

      t.timestamps
    end

    add_index :accreditation_type_keywords, [:accreditation_type, :keyword_match], name: 'index_type_and_keyword_match', unique: true
  end
end

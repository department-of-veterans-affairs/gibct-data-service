class AddTypeKeywordToAcrreditationRecord < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :accreditation_records, :accreditation_type_keyword_id, :bigint, null: true
    add_index :accreditation_records, :accreditation_type_keyword_id, algorithm: :concurrently

    add_foreign_key :accreditation_records,
                    :accreditation_type_keywords,
                    column: :accreditation_type_keyword_id,
                    validate: false,
                    on_delete: :nullify
  end
end

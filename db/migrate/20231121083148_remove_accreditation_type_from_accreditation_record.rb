class RemoveAccreditationTypeFromAccreditationRecord < ActiveRecord::Migration[6.1]
  # The strong migrations gem indicated to be safe that we need to add
  # self.ignored_columns = ["accreditation_type"] to the AccreditationRecord model.
  # I think we can safely ignore that as the table is not heavily used.
  # However, safety_assured is still required.
  def change
    safety_assured { remove_column :accreditation_records, :accreditation_type, :string }
  end
end

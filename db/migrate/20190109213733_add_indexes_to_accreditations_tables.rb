class AddIndexesToAccreditationsTables < ActiveRecord::Migration
  def change
    add_index :accreditation_institute_campuses, :dapip_id
    add_index :accreditation_institute_campuses, :ope
    add_index :institutions, :ope
    add_index :accreditation_records, :dapip_id
    add_index :accreditation_actions, :dapip_id
  end
end

class CreateVersionedComplaintsArchives < ActiveRecord::Migration[7.1]
  def change
    create_table :versioned_complaints_archives do |t|
      t.bigint :version_id
      t.string :status
      t.string :ope
      t.string :ope6
      t.string :facility_code
      t.string :closed_reason
      t.string :issues
      t.integer :cfc, default: 0
      t.integer :cfbfc, default: 0
      t.integer :cqbfc, default: 0
      t.integer :crbfc, default: 0
      t.integer :cmbfc, default: 0
      t.integer :cabfc, default: 0
      t.integer :cdrbfc, default: 0
      t.integer :cslbfc, default: 0
      t.integer :cgbfc, default: 0
      t.integer :cctbfc, default: 0
      t.integer :cjbfc, default: 0
      t.integer :ctbfc, default: 0
      t.integer :cobfc, default: 0
      t.string :case_id
      t.string :level
      t.string :case_owner
      t.string :institution
      t.string :city
      t.string :state
      t.string :submitted
      t.string :closed
      t.string :education_benefits

      t.timestamps
    end
  end
end

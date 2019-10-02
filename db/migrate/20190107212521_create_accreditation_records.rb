class CreateAccreditationRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :accreditation_records do |t|
      t.integer :dapip_id
      t.integer :agency_id
      t.string :agency_name
      t.integer :program_id
      t.string :program_name
      t.integer :sequential_id
      t.string :initial_date_flag
      t.date :accreditation_date
      t.string :accreditation_status
      t.date :review_date
      t.string :department_description
      t.date :accreditation_end_date
      t.integer :ending_action_id
      t.string :accreditation_type

      t.timestamps null: false
    end

    add_index :accreditation_records, :dapip_id
  end
end

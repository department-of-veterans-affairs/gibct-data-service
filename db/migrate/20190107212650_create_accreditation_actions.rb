class CreateAccreditationActions < ActiveRecord::Migration[4.2]
  def change
    create_table :accreditation_actions do |t|
      t.integer :dapip_id
      t.integer :agency_id
      t.string :agency_name
      t.integer :program_id
      t.string :program_name
      t.integer :sequential_id
      t.string :action_description
      t.date :action_date
      t.string :justification_description
      t.string :justification_other
      t.date :end_date

      t.timestamps null: false
    end

    add_index :accreditation_actions, :dapip_id
  end
end

class CreateCrosswalkIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :crosswalk_issues do |t|
      t.integer :weam_id
      t.integer :crosswalk_id
      t.integer :ipeds_hd_id
    end
  end
end

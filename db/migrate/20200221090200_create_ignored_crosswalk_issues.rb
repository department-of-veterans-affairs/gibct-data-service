class CreateIgnoredCrosswalkIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :ignored_crosswalk_issues do |t|
      t.string :facility_code
      t.string :cross
      t.string :ope
    end
  end
end

class CreateCrosswalkIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :crosswalk_issues do |t|
      t.belongs_to :weam, foreign_key: true
      t.belongs_to :crosswalk, foreign_key: true
      t.belongs_to :ipeds_hd, foreign_key: true
    end
  end
end

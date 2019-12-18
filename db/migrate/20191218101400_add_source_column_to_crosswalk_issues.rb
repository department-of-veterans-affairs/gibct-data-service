class AddSourceColumnToCrosswalkIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :crosswalk_issues, :source, :string
  end
end

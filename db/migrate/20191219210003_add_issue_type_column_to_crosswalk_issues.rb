class AddIssueTypeColumnToCrosswalkIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :crosswalk_issues, :issue_type, :string
  end
end

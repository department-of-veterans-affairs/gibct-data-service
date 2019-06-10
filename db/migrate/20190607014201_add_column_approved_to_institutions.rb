class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    # Note this is going to result in null values, three-state-boolean problem
    add_column :institutions, :approved, :boolean, null: false
  end
end

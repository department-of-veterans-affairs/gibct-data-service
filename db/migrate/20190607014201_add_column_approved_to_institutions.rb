class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :approved, :boolean, null: false
  end
end

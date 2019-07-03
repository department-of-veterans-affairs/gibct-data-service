class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :approved, :boolean
  end
end

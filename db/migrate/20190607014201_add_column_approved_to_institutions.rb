class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :approved, :boolean, null: false, default: false
    reversible do |dir|
      dir.up do
        Institution.update_all(approved: true)
      end
    end
  end
end

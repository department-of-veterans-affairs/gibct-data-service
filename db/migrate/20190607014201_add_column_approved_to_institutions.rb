# Define `table_name` in a custom named class to make sure that you run on the
# same table you had during the creation of the migration.
# In future if you override the `Product` class and change the `table_name`,
# it won't break the migration or cause serious data corruption.
class InstitutionModel < ActiveRecord::Base
  self.table_name = :institutions
end

class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :approved, :boolean, null: false, default: false
    reversible do |dir|
      dir.up do
        InstitutionModel.update_all(approved: true)
      end
    end
  end
end

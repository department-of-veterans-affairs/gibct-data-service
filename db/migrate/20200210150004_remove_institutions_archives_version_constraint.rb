
class RemoveInstitutionsArchivesVersionConstraint < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    change_column_null :institutions_archives, :version, true
  end
end

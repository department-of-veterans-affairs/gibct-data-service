class AddVersionIdColumnToInstitutions < ActiveRecord::Migration[5.1]
  def change
    add_column :institutions, :version_id, :integer
  end
end

class AddOwnershipFieldsInstitutions < ActiveRecord::Migration[6.1]
  def change
  	add_column :institutions, :chief_officer, :string
  	add_column :institutions, :ownership_name, :string
  	add_column :institutions_archives, :chief_officer, :string
  	add_column :institutions_archives, :ownership_name, :string
  end
end

class AddInstitutionSearchArchive < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :institution_search, :string
  end
end

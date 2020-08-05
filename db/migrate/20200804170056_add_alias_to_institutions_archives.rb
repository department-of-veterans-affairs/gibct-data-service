class AddAliasToInstitutionsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :alias, :string
  end
end

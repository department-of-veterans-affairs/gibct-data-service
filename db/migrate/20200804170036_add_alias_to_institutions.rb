class AddAliasToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :alias, :string
  end
end

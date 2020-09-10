class AddInstitutionSearch < ActiveRecord::Migration[5.2]
  def change
    add_column :weams, :institution_search, :string
    add_column :institutions, :institution_search, :string
  end
end

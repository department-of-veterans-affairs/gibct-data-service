class AddStemOfferedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :stem_offered, :boolean
  end
end

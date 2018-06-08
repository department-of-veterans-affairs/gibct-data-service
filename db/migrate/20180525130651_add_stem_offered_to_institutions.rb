class AddStemOfferedToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :stem_offered, :boolean, default: false, index: true
  end
end

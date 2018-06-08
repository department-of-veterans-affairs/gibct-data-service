class ChangeDefaultsAddIndexForStemOfferedOnInstitutions < ActiveRecord::Migration
  def change
    change_column_default :institutions, :stem_offered, false
    add_index :institutions, :stem_offered
  end
end

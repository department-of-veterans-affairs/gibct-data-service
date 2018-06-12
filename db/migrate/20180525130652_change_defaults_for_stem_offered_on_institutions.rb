class ChangeDefaultsForStemOfferedOnInstitutions < ActiveRecord::Migration
  def change
    change_column_default :institutions, :stem_offered, false
  end
end

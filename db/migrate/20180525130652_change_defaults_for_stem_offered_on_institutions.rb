class ChangeDefaultsForStemOfferedOnInstitutions < ActiveRecord::Migration[4.2]
  def change
    change_column_default :institutions, :stem_offered, false
  end
end

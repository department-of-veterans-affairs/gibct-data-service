class AddColumnStemIndicatorToInstitution < ActiveRecord::Migration[4.2]
  def up
    add_column :institutions, :stem_indicator, :boolean
    change_column_default :institutions, :stem_indicator, false
  end

  def down
    remove_column :institutions, :stem_indicator
  end
end

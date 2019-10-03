class AddColumnStemIndicatorToWeams < ActiveRecord::Migration[4.2]
    def up
      add_column :weams, :stem_indicator, :boolean
      change_column_default :weams, :stem_indicator, false
    end
  
    def down
      remove_column :weams, :stem_indicator
    end
  end
class AddColumnStemIndicatorToWeams < ActiveRecord::Migration
    def change
      add_column :weams, :stem_indicator, :boolean, default: false, null: false
    end
  end
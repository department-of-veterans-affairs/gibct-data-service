class AddColumnStemIndicatorToWeams < ActiveRecord::Migration
    def change
      add_column :weams, :stem_indicator, :boolean
    end
  end
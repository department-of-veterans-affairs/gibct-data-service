class AddColumnStemIndicatorToWeams < ActiveRecord::Migration
    def change
      # Note this is going to result in null values, three-state-boolean problem
      add_column :weams, :stem_indicator, :boolean
    end
  end
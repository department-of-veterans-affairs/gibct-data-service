class AddScorecardColumnsToInstitutions < ActiveRecord::Migration[5.1]
    def change
        add_column :institutions, :hbcu, :integer
        add_column :institutions, :hcm2, :integer
        add_column :institutions, :menonly, :integer
        add_column :institutions, :pctfloan, :float
        add_column :institutions, :relaffil, :integer
        add_column :institutions, :womenonly, :integer
    end
  end
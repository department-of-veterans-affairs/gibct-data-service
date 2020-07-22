class AddScorecardColumnsToInstitutionsArchives < ActiveRecord::Migration[5.1]
    def change
        add_column :institutions_archives, :hbcu, :integer
        add_column :institutions_archives, :hcm2, :integer
        add_column :institutions_archives, :menonly, :integer
        add_column :institutions_archives, :pctfloan, :float
        add_column :institutions_archives, :relaffil, :integer
        add_column :institutions_archives, :womenonly, :integer
    end
  end
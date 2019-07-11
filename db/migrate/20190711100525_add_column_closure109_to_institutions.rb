class AddColumnClosure109ToInstitutions < ActiveRecord::Migration
    def change
      add_column :institutions, :closure109, :boolean
    end
  end
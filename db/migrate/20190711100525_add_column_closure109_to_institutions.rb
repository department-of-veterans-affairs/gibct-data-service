class AddColumnClosure109ToInstitutions < ActiveRecord::Migration[4.2]
    def change
      add_column :institutions, :closure109, :boolean
    end
  end
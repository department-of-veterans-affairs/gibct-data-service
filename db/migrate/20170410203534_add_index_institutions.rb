class AddIndexInstitutions < ActiveRecord::Migration[4.2]
  def change
    add_index :institutions, :version
    add_index :institutions, :cross
    add_index :institutions, :ope6
  end
end

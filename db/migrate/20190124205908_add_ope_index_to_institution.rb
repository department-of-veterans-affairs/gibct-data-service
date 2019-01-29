class AddOpeIndexToInstitution < ActiveRecord::Migration
  def change
    add_index :institutions, :ope
  end
end

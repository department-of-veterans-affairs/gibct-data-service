class AddOpeIndexToInstitution < ActiveRecord::Migration[4.2]
  def change
    add_index :institutions, :ope
  end
end

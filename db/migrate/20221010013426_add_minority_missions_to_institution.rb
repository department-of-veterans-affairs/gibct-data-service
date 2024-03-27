class AddMinorityMissionsToInstitution < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions, :hsi, :integer
    add_column :institutions, :nanti, :integer
    add_column :institutions, :annhi, :integer
    add_column :institutions, :aanapii, :integer
    add_column :institutions, :pbi, :integer
    add_column :institutions, :tribal, :integer
  end
end

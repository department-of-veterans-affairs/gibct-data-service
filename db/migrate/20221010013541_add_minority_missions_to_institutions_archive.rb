class AddMinorityMissionsToInstitutionsArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions_archives, :hsi, :integer
    add_column :institutions_archives, :nanti, :integer
    add_column :institutions_archives, :annhi, :integer
    add_column :institutions_archives, :aanapii, :integer
    add_column :institutions_archives, :pbi, :integer
    add_column :institutions_archives, :tribal, :integer
  end
end

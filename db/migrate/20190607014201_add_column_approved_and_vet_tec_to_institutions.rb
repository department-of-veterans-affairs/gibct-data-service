class AddColumnApprovedAndVetTecToInstitutions < ActiveRecord::Migration
  def up
    change_table(:institutions, bulk: true) do |t|
      t.column :approved, :boolean 
      t.column :vet_tec_provider, :boolean

      t.change_default :approved, false
      t.change_default :vet_tec_provider, false
    end
  end

  def down
    remove_column :institutions, :approved
    remove_column :institutions, :vet_tec_provider
  end
end

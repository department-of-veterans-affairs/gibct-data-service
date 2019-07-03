class AddColumnVetTecProviderToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :vet_tec_provider, :boolean, null: false
  end
end
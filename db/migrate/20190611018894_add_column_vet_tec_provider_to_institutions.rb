class AddColumnVetTecProviderToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :vet_tec_provider, :boolean, default: false, null: false
  end
end
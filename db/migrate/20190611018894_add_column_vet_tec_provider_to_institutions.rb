class AddColumnVetTecProviderToInstitutions < ActiveRecord::Migration
  def change
    # Note this is going to result in null values, three-state-boolean problem
    add_column :institutions, :vet_tec_provider, :boolean, default: false, null: false
  end
end
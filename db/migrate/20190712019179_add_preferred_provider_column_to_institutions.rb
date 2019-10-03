class AddPreferredProviderColumnToInstitutions < ActiveRecord::Migration[4.2]
  def up
    add_column :institutions, :preferred_provider, :boolean
    change_column_default :institutions, :preferred_provider, false
  end

  def down
    remove_column :institutions, :preferred_provider
  end
end
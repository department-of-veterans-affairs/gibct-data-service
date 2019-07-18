class AddPreferredProviderColumnToWeams < ActiveRecord::Migration
    def up
      add_column :weams, :preferred_provider, :boolean
      change_column_default :weams, :preferred_provider, false
    end
  
    def down
      remove_column :weams, :preferred_provider
    end
  end
class AddPreferredProviderColumnToWeams < ActiveRecord::Migration
    def change
      add_column :weams, :preferred_provider, :boolean
    end
  end
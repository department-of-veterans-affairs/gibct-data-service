# frozen_string_literal: true

class RemoveInstitutionsArchivesIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      ActiveRecord::Base.connection.indexes('institutions_archives').map(&:name).each do |index_name|
        remove_index :institutions_archives, name: index_name, algorithm: :concurrently
      end
    end
  end
end

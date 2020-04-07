class AddCountOfCautionFlagsColumnToInstitutionsArchives < ActiveRecord::Migration[5.2]
    def change
        add_column :institutions_archives, :count_of_caution_flags, :integer, :default => 0
      end
  end
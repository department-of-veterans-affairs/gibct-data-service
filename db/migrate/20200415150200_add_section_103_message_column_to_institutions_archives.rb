class AddSection103MessageColumnToInstitutionsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions_archives, :section_103_message, :string
  end
end

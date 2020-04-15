class AddSection103MessageColumnToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :section_103_message, :string
  end
end

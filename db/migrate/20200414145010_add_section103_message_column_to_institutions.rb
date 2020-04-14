class AddSection103MessageColumnToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :section103_message, :string
  end
end

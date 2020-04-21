class RemoveDefaultFromInstitutions < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:institutions, :section_103_message, nil)
  end
end

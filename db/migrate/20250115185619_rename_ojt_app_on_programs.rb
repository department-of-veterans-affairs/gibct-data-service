class RenameOjtAppOnPrograms < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :programs, :ojt_app }
    add_column :programs, :ojt_app_type, :string
  end
end

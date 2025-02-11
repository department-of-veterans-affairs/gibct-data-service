class AddOjtAppTypeToPrograms < ActiveRecord::Migration[7.1]
  def change
    add_column :programs, :ojt_app_type, :string
  end
end

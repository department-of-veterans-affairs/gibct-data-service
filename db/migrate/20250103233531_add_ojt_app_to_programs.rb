class AddOjtAppToPrograms < ActiveRecord::Migration[7.1]
  def change
    add_column :programs, :ojt_app, :string
  end
end

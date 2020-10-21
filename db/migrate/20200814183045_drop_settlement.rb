class DropSettlement < ActiveRecord::Migration[5.2]
  def change
    drop_table :settlements, if_exists: true
  end
end

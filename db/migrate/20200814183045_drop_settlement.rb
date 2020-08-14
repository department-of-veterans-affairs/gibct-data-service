class DropSettlement < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("settlements")
      drop_table :settlements
    end
  end
end

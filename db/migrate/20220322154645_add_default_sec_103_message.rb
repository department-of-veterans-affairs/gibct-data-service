class AddDefaultSec103Message < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:institutions, :section_103_message, from: nil, to: "No")
  end
end
